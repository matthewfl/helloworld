#include "catch.hpp"
#include "hello_world.h"

TEST_CASE("hello world", "[helloWorld]") {
	HelloWorld hw;
	REQUIRE(&hw != NULL);
	hw.sayHi();
}
