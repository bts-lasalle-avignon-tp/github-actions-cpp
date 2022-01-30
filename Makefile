TARGET = main.out
SOURCES = main.cpp IHM.cpp
OBJS = main.o IHM.o
RM = rm -f
CXX = g++ -c 
LD = g++ -o

$(TARGET): $(OBJS)
	$(LD) $@ $^

main.o: main.cpp
	$(CXX) $<

IHM.o: IHM.cpp IHM.h
	$(CXX) $<

check:
	clang-tidy $(SOURCES) --quiet -header-filter='.*' -checks=-*,boost-*,bugprone-*,performance-*,readability-*,portability-*,modernize-use-nullptr,clang-analyzer-*,cppcoreguidelines-* --format-style=none -- -std=c++11

cppcheck:
	cppcheck --enable=all --std=c++11 --platform=unix64 --suppress=missingIncludeSystem --quiet $(SOURCES)

format:
	find . -regex '.*\.\(cpp\|h\)' -exec clang-format -i --style=file {} \;

clean:
	$(RM) *.o

cleanall:
	$(RM) $(OBJS) $(TARGET)
