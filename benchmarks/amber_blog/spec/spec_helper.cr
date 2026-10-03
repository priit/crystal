require "spec"
require "../config/*"
require "../src/controllers/**"
require "../src/models/**"
require "../src/schemas/**"
require "../src/jobs/**"
require "../src/mailers/**"
require "../src/channels/**"

# Amber Testing Framework
require "amber/testing/testing"

# Include test helpers globally
include Amber::Testing::RequestHelpers
include Amber::Testing::Assertions
