# frozen_string_literal: true

# Wile namespace.
module Wile
  # BSD sysexits(3) exit status codes.
  # :reek:TooManyConstants
  module Sysexits
    EX_OK          = 0   # success
    EX_FAIL        = 1   # test|task failed
    EX_NO          = 1   # request was rejected|declined
    EX_USAGE       = 64  # command used incorrectly
    EX_DATAERR     = 65  # input data incorrect
    EX_NOINPUT     = 66  # input file missing or unreadable
    EX_NOUSER      = 67  # reserved: user unknown
    EX_NOHOST      = 68  # reserved: host unknown
    EX_UNAVAILABLE = 69  # required command, gem, or service unavailable
    EX_SOFTWARE    = 70  # internal software error
    EX_OSERR       = 71  # system call or subprocess error
    EX_OSFILE      = 72  # system or template file missing|corrupt
    EX_CANTCREAT   = 73  # output file cannot be created
    EX_IOERR       = 74  # input|output error
    EX_TEMPFAIL    = 75  # temporary failure; retry may succeed
    EX_PROTOCOL    = 76  # remote protocol error
    EX_NOPERM      = 77  # permission denied
    EX_CONFIG      = 78  # configuration or project state error
  end
end
