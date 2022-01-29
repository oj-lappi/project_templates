#include "{{project_name}}.hpp"
#include <nlohmann/json.hpp>

#if defined(CATCH2_USE_OLD_HEADER)
#    include <catch2/catch.hpp>
#else
#    include <catch2/catch_test_macros.hpp>
#endif

TEST_CASE("Dummy serialization test", "[serialization]")
{
	CHECK(1 == 1);
}
