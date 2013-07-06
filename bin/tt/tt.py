#!/usr/bin/env python2.5
import sys
import os
import datetime, time
from optparse import OptionParser
from getpass import getuser
try:
    from sqlite3 import connect, PARSE_DECLTYPES, PARSE_COLNAMES
except ImportError:
    try:
        from sqlite import connect, PARSE_DECLTYPES, PARSE_COLNAMES
    except ImportError:
        sys.stderr.write('Could not import sqlite3 or sqlite\n')
        sys.exit(1)

class Verbosity(object):
    (QUIET,
    NORMAL,
    INFO,
    DEBUG) = range(4)

class BaseExceptions(Exception): pass
class Warning(BaseException): pass
class UnknownAction(BaseException): pass
class InvalidParameter(BaseException): pass
class InvalidProject(BaseException): pass
class NoDatabase(BaseException): pass
class NoCurrentProject(BaseException): pass

def conn_cursor(db, check=True):
    "Return a connection to DB and a cursor for it"
    if check and not os.path.exists(db):
        raise NoDatabase
    conn = connect(db, detect_types=PARSE_DECLTYPES|PARSE_COLNAMES)
    cursor = conn.cursor()
    return conn, cursor

def shutdown_conn(conn):
    "Commit and close the connection"
    conn.commit()
    conn.close()

def get_last_id(cursor):
    cursor.execute("SELECT last_insert_rowid()")
    return cursor.fetchone()[0]

def utc_to_local(dt):
    offset = datetime.timedelta(seconds=time.timezone)
    return dt - offset

def format_time(seconds, show_as_decimal=False):
    if show_as_decimal:
        return "%0.1f minute(s)" % round(seconds / 60.0, 1)
    else:
        m, s = divmod(seconds, 60)
        h, m = divmod(m, 60)
        return "%03i:%02i:%02i" % (h,m,s)

def new_project(cursor, name, default=True):
    cursor.execute("""SELECT count(*) FROM projects WHERE name=?""", (name,))
    exists = cursor.fetchone()[0] > 0
    if exists:
        raise InvalidProject, "Project already exists."
    else:
        if default:
            cursor.execute("""UPDATE projects SET current=?""", (False,))
        cursor.execute("""
            INSERT INTO projects (name, current)
            VALUES (?, ?)
            """, (name, default))
        return get_last_id(cursor)

def end_time(cursor, when):
    cursor.execute("UPDATE times SET end=? WHERE end IS NULL", (when,))

def start_time(cursor, id, desc=None):
    now = datetime.datetime.utcnow()
    end_time(cursor, now)
    cursor.execute("""INSERT INTO times
        (projid, start, note) VALUES (?,?,?)""",
        (id, now, desc))
    return now

def init(action, options, args):
    """Initialize the DB
    Takes an optional parameter for the default task-name
    INIT "Some project" Some note for the task
    """
    db = options.db
    if os.path.exists(db):
        if options.forceinit:
            os.unlink(db)
        else:
            raise Warning, "%s already exists (use --force to override)" % db
    conn, cursor = conn_cursor(db, False)
    cursor.execute("""
        CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name CHAR(30) UNIQUE NOT NULL COLLATE NOCASE,
        current BIT,
        deleted BIT DEFAULT 0
        )""")
    cursor.execute("""
        CREATE TABLE times (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projid INTEGER REFERENCES Projects(id),
        start TIMESTAMP NOT NULL,
        end TIMESTAMP,
        note TEXT
        )""")
    cursor.execute("""
        CREATE TABLE marks (
        projid INTEGER REFERENCES Projects(id),
        mark TIMESTAMP NOT NULL,
        note TEXT
        )
        """)
    if args:
        taskname = args[0]
    else:
        taskname = 'Default'
    projid = new_project(cursor, taskname, True)
    remaining_args = args[1:]
    if remaining_args:
        params = [cursor, projid]
        if len(args) > 1:
            title = ' '.join(remaining_args)
            params.append(title)
        start_time(*params)
    shutdown_conn(conn)
    if options.verbosity > Verbosity.QUIET:
        s = "Created project %(name)s with ID %(id)i"
    else:
        s = "%(id)i: %(name)s"
    return [s % {
        'name': taskname,
        'id': projid,
        }]

def add(action, options, args):
    '''[+]<project-name>    Add a new project
    The default project is set to <project-name> unless prefixed by "+"'''
    if len(args) < 1:
        raise InvalidParameter, "Must supply the project-name"
    conn, cursor = conn_cursor(options.db)
    try:
        taskname = ' '.join(args)
        make_default = not taskname.startswith('+')
        if not make_default: taskname = taskname[1:]
        if not taskname: # just a minus sign
            raise InvalidParameter, "Must supply a valid project-name"
        projid = new_project(cursor, taskname, make_default)
    except:
        shutdown_conn(conn)
        raise
    shutdown_conn(conn)
    if options.verbosity > Verbosity.QUIET:
        s = "Created project %(name)s with ID %(id)i"
    else:
        s = "%(id)i: %(name)s"
    return [s % {
        'name': taskname,
        'id': projid,
        }]

def ls(action, options, args):
    """[id] list available projects, or time spent on a given project
    Without [id], lists all projects
    With [id], lists total time spent on that project"""
    conn, cursor = conn_cursor(options.db)
    try:
        results = []
        if args:
            try:
                id = int(args[0])
            except ValueError:
                raise InvalidParameter, "Malformed project ID"
            cursor.execute("""SELECT
                name, current
                FROM projects
                WHERE id=?""", (id, ))
            row = cursor.fetchone()
            if not row:
                raise InvalidProject, "Could not find project #%i" % id
            name, current = row

            cursor.execute("""
                SELECT start, end, note
                FROM times
                WHERE projid=?
                ORDER BY end, start, note
                """, (id,))
            rows = cursor.fetchall()
            if not rows: return ["No entries for project #%i" % id]
            total_time = datetime.timedelta(seconds=0)
            
            for start, end, note in rows:
                if end:
                    time_spent = end - start
                    line = "%s to %s: %s" % (
                        utc_to_local(start).strftime(options.time_format),
                        utc_to_local(end).strftime(options.time_format),
                        format_time(time_spent.seconds),
                        )
                    if note:
                        line += ' spent on "%s"' % note
                else:
                    now = datetime.datetime.utcnow()
                    time_spent = now - start
                    line = '%s Current' % (
                        utc_to_local(start).strftime(options.time_format))
                    if note:
                        line += 'ly working on "%s"' % note
                results.append(line)
                total_time += time_spent
            results.append("Total time: %s minutes" %
                format_time(total_time.seconds))
        else: # just list the projects
            sql = """SELECT
                p.id, p.name, p.current, p.deleted, sum(
                    strftime("%s", coalesce(t.end, current_timestamp))
                    - strftime("%s", t.start)
                    ) as seconds
                FROM projects p
                    INNER JOIN times t
                    ON t.projid = p.id"""
            if not options.deleted:
                sql += " WHERE deleted = 0"
            sql += """
            GROUP BY 
                p.id, p.name, p.current, p.deleted
            ORDER BY p.current DESC, p.id
            """
            
            cursor.execute(sql)
            format_str = '%(id)i: %(name)s %(time)s Total %(current)s%(deleted)s'
            if options.verbosity > Verbosity.QUIET:
                current_map = {True: ' (Current)', False: ''}
            else:
                current_map = {True: ' *', False: ''}
            for id, name, current, deleted, seconds in cursor.fetchall():
                delstr = deleted and " (Deleted)" or ""
                results.append(format_str % {
                    'id': id,
                    'name': name,
                    'current': current_map[bool(current)],
                    'deleted': delstr,
                    'seconds': seconds,
                    'time': format_time(seconds),
                    })
    except:
        conn.close()
        raise
    return results or ['No items']

def help(self, options, args):
    """provides help
    With no parameter, lists available actions
    With a parameter, lists help for the given action"""
    results = []
    if args:
        kword = args[0].strip().upper()
        action = get_action(kword)
        if options.verbosity > Verbosity.QUIET:
            results.append("Help for %s" % action.name)
            if len(action.aliases) > 1:
                aliases = (alias.lower
                    for alias
                    in action.aliases
                    if alias != action.name
                    )
                results.append("Aliases: %s" % ', '.join(aliases))
        results.append(action.action.__doc__)
    else:
        for name, action in ACTION_MAP.iteritems():
            format = "%s\t%s"
            helpstr = action.action.__doc__.splitlines()[0]
            results.append(format % (name, helpstr))
    return results

def start(action, options, args):
    """Starts the timer on the current task
    If the first parameter is numeric, it will be treated as the project-ID
    and the "current project" will be changed.  Any following content will
    be treated as a note associated with this task.
    If another task is already in progress, it is ended first.
    """
    conn, cursor = conn_cursor(options.db)
    try:
        if args and args[0].isdigit():
            projid = int(args[0])
            args = args[1:]
            name = 'current project'
            cursor.execute("""UPDATE projects SET current=?""", (False,))
            cursor.execute("""UPDATE projects SET current=?
                WHERE id=?""", (True,projid))
        cursor.execute("""SELECT id, name
            FROM Projects
            WHERE current=?""", (True, ))
        row = cursor.fetchone()
        if not row:
            raise InvalidProject, "No current project"
        projid, name = row
        params = [cursor, projid]
        if args: params.append(' '.join(args))
        now = start_time(*params)
    except:
        shutdown_conn(conn)
        raise
    shutdown_conn(conn)
    if options.verbosity > Verbosity.QUIET:
        return ["Started timer for %s at %s" %
            (name, utc_to_local(now).strftime(options.time_format))
            ]
    else:
        return []

def end(action, options, args):
    """Ends the timer on the current task"""
    conn, cursor = conn_cursor(options.db)
    try:
        now = datetime.datetime.utcnow()
        end_time(cursor, now)
    except:
        shutdown_conn(conn)
        raise
    shutdown_conn(conn)
    return ['Stopped: %s' % utc_to_local(now).strftime(options.time_format)]

def remove(action, options, args):
    """Mark a project as deleted
    Takes a parameter of the project ID"""
    if len(args) != 1:
        raise InvalidParameter, "Must supply a valid project ID"
    try:
        projid = int(args[0])
    except ValueError:
        raise InvalidParameter, "Malformed project ID: %s" % args[0]
    conn, cursor = conn_cursor(options.db)
    results = ["Deleted"]
    try:
        now = datetime.datetime.utcnow()
        cursor.execute("""
            UPDATE times SET end=?
            WHERE end IS NULL
            AND projid=?""", (now, projid))
        cursor.execute("""
            UPDATE projects SET deleted=?, current=?
            WHERE id=?
            """, (True, False, projid))
        cursor.execute("""SELECT count(*)
            FROM projects
            WHERE current=?""", (True,))
        active_project_count = cursor.fetchone()[0]
        if not active_project_count:
            cursor.execute("""SELECT Max(id)
                FROM projects
                WHERE deleted <> ?""", (True, ))
            projid = cursor.fetchone()[0]
            if projid:
                cursor.execute("""UPDATE projects SET
                    current=?
                    WHERE id=?""", (True, projid))
            else:
                raise NoCurrentProject, "No project is current"
    except:
        shutdown_conn(conn)
        raise
    shutdown_conn(conn)
    return results

def unremove(action, options, args):
    """Removes the deletion-mark from a project
    Takes a parameter of the project ID"""
    if len(args) != 1:
        raise InvalidParameter, "Must supply a valid project ID"
    try:
        projid = int(args[0])
    except ValueError:
        raise InvalidParameter, "Malformed project ID: %s" % args[0]
    conn, cursor = conn_cursor(options.db)
    try:
        cursor.execute("""UPDATE projects SET
            deleted=? WHERE id=?""", (False, projid))
    except:
        shutdown_conn(conn)
        raise
    shutdown_conn(conn)
    return ["Unremoved %i" % projid]

def not_yet_implemented(action, options, args):
    "..."
    return ["%s not yet implemented" % action.name]
    conn, cursor = conn_cursor(options.db)
    try:
        pass
    except:
        shutdown_conn(conn)
        raise
    shutdown_conn(conn)
    return []

class Actions(object):
    HELP = 'HELP'
    INIT = 'INIT'
    ADD = 'ADD'
    START = 'START'
    STOP = 'STOP'
    LIST = 'LIST'
    REMOVE = 'REMOVE'
    UNREMOVE = 'UNREMOVE'
    #WIPE = 'WIPE'

class Action(object):
    def __init__(self, name, action, aliases=None):
        self.name = name.upper()
        self.action = action
        self.aliases = set(s.upper() for s in (aliases or []))
        self.aliases.add(self.name)
    def __str__(self):
        s = self.name
        if self.aliases:
            s += ' (%s)' % ','.join(
                alias for alias in self.aliases if alias != self.name)
        s += '\n'
        s += self.action.__doc__
        return s

ACTION_MAP = {
    Actions.HELP: Action(Actions.HELP, help),
    Actions.INIT: Action(Actions.INIT, init),
    Actions.ADD: Action(Actions.ADD, add),
    Actions.START: Action(Actions.START, start, ['begin']),
    Actions.STOP: Action(Actions.STOP, end, ['end', 'done']),
    Actions.LIST: Action(Actions.LIST, ls, ['ls', 'dir']),
    Actions.REMOVE: Action(
        Actions.REMOVE,
        remove,
        ['rm', 'del', 'delete']),
    Actions.UNREMOVE: Action(
        Actions.UNREMOVE,
        unremove,
        ['unrm', 'undel', 'undelete']
        ),
    #Actions.WIPE: Action(
    #   Actions.WIPE,
    #   not_yet_implemented,
    #   ['nuke']),
    }

def get_action(s):
    s = s.strip().upper()
    if s in ACTION_MAP:
        return ACTION_MAP[s]
    for name, action in ACTION_MAP.iteritems():
        if s in action.aliases:
            return action
    raise UnknownAction, "Unknown action [%s]" % s

if __name__ == "__main__":
    location = os.path.expanduser('~/.timetrack')
    configfile = os.path.join(location, 'config.ini')
    if not os.path.exists(location):
        os.makedirs(location)

    parser = OptionParser(
        usage="Usage: %prog [options] ACTION [action parameters]",
        version='%prog 0.1',
        )
    parser.add_option('-d', '--database',
        help="The database file to use",
        action='store',
        dest='db',
        metavar='FILE')
    parser.add_option('-a', '--all',
        help="Include deleted tasks",
        action='store_true',
        dest='deleted')
    parser.add_option('--format',
        help="Time format (see help on Python's strftime)",
        action='store',
        dest='time_format')
    parser.add_option('-v', '--verbose',
        help="Adjust the verbosity",
        action='count',
        dest='verbosity')
    parser.add_option('-f', '--forceinit',
        help="Force the initialization of an existing database",
        action='store_true',
        dest='forceinit',
        )
    parser.add_option('-q', '--quiet',
        help="Only necessary information",
        action='store_const',
        const=Verbosity.QUIET,
        dest='verbosity')
    parser.set_defaults(
        verbosity=Verbosity.NORMAL,
        db=os.path.join(location, '%s.db' % getuser()),
        forceinit=False,
        deleted=False,
        time_format='%Y-%m-%d %H:%M:%S', # 24-hr, with seconds
        #time_format='%Y-%m-%d %I:%M:%S%p', # 12-hr + AM/PM, with seconds
        )

    options, args = parser.parse_args()
    if not args:
        parser.print_help()
        sys.exit(1)

    if options.verbosity >= Verbosity.DEBUG:
        print 'Using', options.db
    try:
        action = get_action(args[0])
    except UnknownAction:
        parser.print_help()
        sys.exit(1)
    try:
        print '\n'.join(action.action(action, options, args[1:]))
    except (BaseException), w:
        print w