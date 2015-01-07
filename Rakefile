require 'xcjobs'

XCJobs::Build.new do |t|
  t.project = 'SimpleCache'
  t.scheme = 'SimpleCache'
  t.configuration = 'Release'
  t.build_dir = 'build'
  t.formatter = 'xcpretty -c'
  t.add_build_setting('CODE_SIGN_IDENTITY', '')
  t.add_build_setting('CODE_SIGNING_REQUIRED', 'NO')
  t.add_build_setting('GCC_SYMBOLS_PRIVATE_EXTERN', 'NO')
end

XCJobs::Test.new do |t|
  t.project = 'SimpleCache'
  t.scheme = 'SimpleCache'
  t.configuration = 'Release'
  t.build_dir = 'build'
  t.add_destination('name=iPhone 5s,OS=7.1')
  t.add_destination('name=iPhone 5s,OS=8.1')
  t.formatter = 'xcpretty -c'
  t.add_build_setting('GCC_INSTRUMENT_PROGRAM_FLOW_ARCS', 'YES')
  t.add_build_setting('GCC_GENERATE_TEST_COVERAGE_FILES', 'YES')
end
