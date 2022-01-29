#include "utils/file.h"

// POSIX dirname
#include <libgen.h>
// POSIX fstat
#include <sys/stat.h>

// FILE, fwrite, fopen
#include <cstdio>

// create_directory
#include <filesystem>

void
file_closer::operator()(std::FILE *fp)
{
    if (fp == nullptr) {
        return;
    }

    int ret = std::fclose(fp); // NOLINT(cppcoreguidelines-owning-memory)
    if (ret != 0) {
        // TODO: throw
        printf("Error closing file (file_closer)\n");
    }
}

void
file_handle::open(const std::string &filename_, const std::string &mode)
{
    close();
    filename = filename_;

    // TODO: only do this if we're writing to a file
    std::filesystem::path p = std::filesystem::u8path(filename);
    if (p.has_parent_path()) {
        std::filesystem::create_directories(p.parent_path());
    }

    // Could also go fd = open(filename.c_str(), O_CREAT | O_WRONLY | O_CLOEXEC | O_APPEND, 0644);
    //  ... or similar
    //           and fp = fdopen(fd, "ab");
    fp = unique_file_ptr(fopen(filename.c_str(), mode.c_str()));

    if (!fp) {
        // TODO: throw
        printf("Error opening file %s\n", filename.c_str());
        state = FileState::ErrorOpening;
    }
    state = FileState::Open;
}

void
file_handle::close()
{
    fp.reset();
    state = FileState::Initial;
}

void
file_handle::write(const std::string &str) const
{
    size_t length = str.length();
    if (fwrite(str.data(), 1, length, fp.get()) != length) {
        // TODO:throw
    }
}

std::string
file_handle::slurp() const
{
    // NOLINTBEGIN()
    std::string str;
    if (!fp) {
        // TODO:throw
        return str;
    }
    int         fd = fileno(fp.get());
    struct stat statbuf {
    };
    fstat(fd, &statbuf);

    size_t file_len = statbuf.st_size;
    char  *filebuf  = new char[file_len + 1]; // NOLINT(cppcoreguidelines-owning-memory)

    if (filebuf == nullptr) {
        // TODO: throw?, couldn't allocate memory. Highly unlikely
        delete[] filebuf; // NOLINT(cppcoreguidelines-owning-memory)
        return str;
    }

    size_t n = 0;
    if ((n = fread(filebuf, file_len, 1, fp.get())) != 1) {
        // TODO: throw?, error reading
        printf("Error reading file, n = %lu\n", n);
    }
    filebuf[file_len] = '\0'; // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
    str               = filebuf;
    delete[] filebuf; // NOLINT(cppcoreguidelines-owning-memory)
    return str;
}

void
file_handle::flush() const
{
    if (fflush(fp.get()) != 0) {
        // TODO: throw
    }
}
