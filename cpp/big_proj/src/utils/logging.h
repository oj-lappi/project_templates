#include "nlohmann/json.hpp"
#include "utils/file.h"

// Simple structured logging with json
template <typename T>
concept json_convertible = requires(T msg)
{
    static_cast<nlohmann::json>(msg);
};

struct JsonLogger {
    file_handle logfile;

    JsonLogger(std::string logfile_path) : logfile{} { logfile.open(logfile_path, "ab"); }

    void
    Log(const json_convertible auto msg)
    {
        nlohmann::json j   = msg;
        std::string    str = j.dump() + "\n";
        logfile.write(str);
    }
};

struct LineLogger {
    file_handle logfile;

    LineLogger(std::string logfile_path) : logfile{} { logfile.open(logfile_path, "ab"); }

    void
    Log(const std::string msg)
    {
        logfile.write(msg);
    }
};
