#include <cstdio>
#include <string>

// POSIX dirname
#include <libgen.h>

// unique_ptr
#include <memory>

// TODO: handle errors?
// TODO: model access mode?

enum FileState { Initial = 0, Open, ErrorOpening };

struct file_closer {
    void operator()(std::FILE *fp);
};

using unique_file_ptr = std::unique_ptr<std::FILE, file_closer>;

struct file_handle {
    unique_file_ptr fp;
    std::string     filename;
    FileState       state;

    void open(const std::string &filename_, const std::string &mode);
    void close();

    // void write(const auto data, const size_t size);
    // void write(const auto data, const size_t size, const size_t n_members);

    void        write(const std::string &str) const;
    std::string slurp() const;
    void        flush() const;

  private:
    void create_parent_dir();
};
