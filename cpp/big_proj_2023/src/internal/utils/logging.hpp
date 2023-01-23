#ifndef {{project_name}}_UTILS_LOGGING_HPP
#define {{project_name}}_UTILS_LOGGING_HPP

#include "internal/utils/file.hpp"

#include <nlohmann/json.hpp>

// Simple structured logging with json
template <typename T>
concept json_convertible = requires(T msg)
{
    static_cast<nlohmann::json>(msg);
};

class JsonLogger {
  public:
    JsonLogger(const std::string &logfile_path) : logfile{} { logfile.open(logfile_path, "ab"); }
    void
    log(const json_convertible auto &msg)
    {
        nlohmann::json j   = msg;
        std::string    str = j.dump() + "\n";
        logfile.write(str);
    }

  private:
    file_handle logfile;
};

class LineLogger {
  public:
    LineLogger(const std::string &logfile_path) : logfile{} { logfile.open(logfile_path, "ab"); }

    void
    log(const std::string &msg)
    {
        logfile.write(msg);
    }

  private:
    file_handle logfile;
};
#endif
