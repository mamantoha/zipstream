require "./spec_helper"

private def run(code)
  code = <<-CR
    require "./src/zipstream"
    Zipstream.config.env = "test"
    #{code}
    CR

  String.build do |stdout|
    String.build do |stderr|
      Process.new("crystal", ["eval", code], output: stdout, error: stderr).wait
    end
  end
end

describe "Run" do
  it "runs" do
    run(<<-CR).should contain "To download the file please use one of the commands below"
      Zipstream.run
      CR
  end
end
