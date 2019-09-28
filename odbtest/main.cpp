﻿#include <iostream>
#include <memory>

#ifdef _WIN32
# ifdef _MSC_VER
#  pragma comment(lib, "Ws2_32.lib") // or #include <boost/asio.hpp>
# endif // _MSC_VER
#endif // _WIN32

#include <odb/transaction.hxx>
#include <odb/pgsql/database.hxx>
#include <odb/schema-catalog.hxx>

#include <soci/soci.h>
#include <soci/postgresql/soci-postgresql.h>

using namespace soci;
using namespace std;


int main()
{
	try
	{
		session sql(postgresql, "user='postgres' dbname='ftest' host='192.168.2.110' port=5432 application_name=odb-release");
		int count;
		sql << "select count(*) from spool_sealed_share", into(count);
		auto bk = sql.get_backend();

		std::unique_ptr<odb::pgsql::connection_factory>
			pool(new odb::pgsql::connection_pool_factory(100, 50));

		auto db = std::make_shared<odb::pgsql::database>("postgres",
			"", "postgres", "192.168.2.110", 5432,
			"application_name=odb-release", std::move(pool));

		auto pghandle = db->connection()->handle();

		odb::transaction t(db->begin());
		if (db->schema_version() == 0)
		{
			t.commit();
			t.reset(db->begin());
			odb::schema_catalog::create_schema(*db, "", true);
			t.commit();
		}
		else
		{
			t.commit();
			t.reset(db->begin());
			odb::schema_catalog::migrate(*db);
			t.commit();
		}
	}
	catch (const std::exception& e)
	{
		std::cerr << e.what() << std::endl;
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
