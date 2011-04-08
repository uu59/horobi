# -- coding: utf-8

module Horobi
  module Pub
    attr_reader :sock

    def self.init
      @context ||= ZMQ::Context.new
      options = {
        "logfile" => STDERR,
        "outputs" => [],
      }
      OptionParser.new do |op|
        op.on('-p VAL','--pidfile=VAL','pidfile path'){|v| options["pidfile"] = v}
        op.on('-l VAL','--logfile=VAL','logfile path'){|v| options["logfile"] = (v == "-" ? STDOUT : v)}
        op.on('-o VAL','--ouput-points=VAL',
          "output(hub's input) point(s) such as 'tcp://127.0.0.1:5551,tcp://127.0.11.1:5551'"){|v| options["outputs"] = v.split(",")}
        op.on('-d','--daemonize','daemonize this script'){ options["daemon"] = true }
        op.parse!(ARGV)
      end
      @options = options
      if @options["outputs"].compact.length < 1
        raise "pub output points are undefined"
      end
      @logger = Logger.new(options["logfile"])
      @sock ||= begin
        sock = @context.socket(ZMQ::PUSH)
        @options["outputs"].each do |point|
          @logger.info("connecting to #{point}")
          sock.connect(point)
        end
        sock.setsockopt(ZMQ::LINGER, 100)
        sock
      end
    end

    def self.send(msg, flags=nil) # flags = ZMQ::NOBLOCK | ZMQ::SNDMORE
      if @options.nil?
        init
      end

      @logger.debug("message send to #{@options["inputs"]}: " + msg)
      @sock.send(msg, flags)
    end

    Horobi.close_hooks do
      @sock.close if @sock
      @context.close if @context
    end
  end
end
