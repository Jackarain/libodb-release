/* file      : test/driver.c
 * copyright : not copyrighted - public domain
 */

/* Basic test to make sure the library is usable.
 */

#ifdef NDEBUG
#  undef NDEBUG
#endif

#include <sqlite3.h>

#include <stddef.h> /* NULL */
#include <assert.h>

static int
sql (sqlite3* db, const char* stmt)
{
  return sqlite3_exec (db, stmt, NULL, NULL, NULL) == SQLITE_OK;
}

int
main ()
{
  sqlite3* db;
  int r;

  r = sqlite3_open_v2 (":memory:",
                       &db,
                       SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
                       NULL);
  assert (r == SQLITE_OK);

  assert (sql (db, "BEGIN"));
  assert (sql (db, "CREATE TABLE test (id INTEGER PRIMARY KEY, str TEXT)"));
  assert (sql (db, "COMMIT"));

  assert (sql (db, "BEGIN"));
  assert (sql (db, "INSERT INTO test VALUES (123, 'abc')"));
  assert (sql (db, "COMMIT"));

  assert (sql (db, "BEGIN"));
  assert (!sql (db, "INSERT INTO test VALUES (123, 'ABC')"));
  assert (sql (db, "ROLLBACK"));

  assert (sql (db, "BEGIN"));
  assert (sql (db, "DROP TABLE test"));
  assert (sql (db, "COMMIT"));

  r = sqlite3_close (db);
  assert (r == SQLITE_OK);

  return 0;
}
