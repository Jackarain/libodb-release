// file      : odb/pgsql/statements-base.hxx
// copyright : Copyright (c) 2005-2019 Code Synthesis Tools CC
// license   : GNU GPL v2; see accompanying LICENSE file

#ifndef ODB_PGSQL_STATEMENTS_BASE_HXX
#define ODB_PGSQL_STATEMENTS_BASE_HXX

#include <odb/pre.hxx>

#include <odb/schema-version.hxx>
#include <odb/details/shared-ptr.hxx>

#include <odb/pgsql/version.hxx>
#include <odb/pgsql/connection.hxx>
#include <odb/pgsql/database.hxx>

#include <odb/pgsql/details/export.hxx>

namespace odb
{
  namespace pgsql
  {
    class LIBODB_PGSQL_EXPORT statements_base: public details::shared_base
    {
    public:
      typedef pgsql::connection connection_type;

      connection_type&
      connection ()
      {
        return conn_;
      }

      // Schema version. database::schema_version_migration() is thread-
      // safe which means it is also slow. Cache the result in statements
      // so we can avoid the mutex lock. This is thread-safe since if the
      // version is updated, then the statements cache will be expired.
      //
      const schema_version_migration&
      version_migration (const char* name = "") const
      {
        if (svm_ == 0)
          svm_ = &conn_.database ().schema_version_migration (name);

        return *svm_;
      }

    public:
      virtual
      ~statements_base ();

    protected:
      statements_base (connection_type& conn): conn_ (conn), svm_ (0) {}

    protected:
      connection_type& conn_;
      mutable const schema_version_migration* svm_;
    };
  }
}

#include <odb/post.hxx>

#endif // ODB_PGSQL_STATEMENTS_BASE_HXX
