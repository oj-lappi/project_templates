#if defined(CATCH2_USE_OLD_HEADER)
#    include <catch2/catch.hpp>
#else
#    include <catch2/catch_all.hpp>
#endif

#include "{{project_name}}.hpp"
#include "nlohmann/json.hpp"
#include "utils/serialization/all.h"

TEST_CASE("Dummy serialization test", "[serialization]")
{
	CHECK(1 == 1);
}
