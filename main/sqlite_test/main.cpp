#include <iostream>
#include <memory>

#include <odb/transaction.hxx>
#include <odb/sqlite/database.hxx>
#include <odb/schema-catalog.hxx>

int main()
{
	try
	{
		auto db = std::make_shared<odb::sqlite::database>("test.db",
			SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);

		{
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

		std::cout << "SQLite ODB test passed!" << std::endl;
	}
	catch (const std::exception& e)
	{
		std::cerr << e.what() << std::endl;
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
