require 'sauce'
module Sauce
  module Jasmine
    class SeleniumDriver
      def initialize(os, browser, browser_version, domain, server, server_host, server_port)
        host = host[7..-1] if host =~ /^http:\/\//
        base_url = "http://#{domain}"

        @driver = Sauce::Selenium2.new(:browser => browser,
                                       :os => os,
                                       :browser_version => browser_version,
                                       :browser_url => base_url,
                                       :record_video => false,
                                       :record_screenshots => false,
                                       :job_name => "Jasmine")

        server_path = "/jasmine" unless server == :jasmine_gem
        @server_uri = URI::HTTP.build(host: server_host, port: server_port, path: server_path)
      end

      def connect
        @driver.navigate.to(@server_uri.to_s)
      end

      def disconnect
        @driver.stop
      end

      def eval_js(script)
        escaped_script = script.gsub(/(['\\])/) { '\\' + $1 }
        result = @driver.execute_script(escaped_script)
        JSON.parse("{\"result\":#{result}}")["result"]
      end

      def tests_have_finished?
        eval_js("return (jsApiReporter && jsApiReporter.finished)")
      end

      def test_suites
        eval_js("var result = jsApiReporter.suites(); if (window.Prototype && Object.toJSON) { return Object.toJSON(result) } else { return JSON.stringify(result) }")
      end

      def test_results
        eval_js("var result = {}; var apiResult = jsApiReporter.results(); for(var i in apiResult) { if(apiResult.hasOwnProperty(i)) { result[i] = {result: apiResult[i].result}; } } if(window.Prototype && Object.toJSON) { return Object.toJSON(result); } else { return JSON.stringify(result); }")
      end

      def job_id
        @driver.session_id
      end
    end
  end
end
