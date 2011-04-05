# -- coding: utf-8

module Horobi
  module Sub
    @context = ZMQ::Context.new

    def self.init
      options = {
        "logfile" => STDERR,
        "inputs" => [],
      }
      OptionParser.new do |op|
        op.on('-p VAL','--pidfile=VAL','pidfile path'){|v| options["pidfile"] = v}
        op.on('-l VAL','--logfile=VAL','logfile path'){|v| options["logfile"] = (v == "-" ? STDOUT : v)}
        op.on('-i VAL','--input-points=VAL',
          "input(hub's output) point(s) such as 'tcp://127.0.0.1:5551,tcp://127.0.11.1:5551'"){|v| options["inputs"] = v.split(",")}
        #op.on('-d','--daemonize','daemonize this script'){ options["daemon"] = true }
        op.parse!(ARGV)
      end
      @options = options
      if @options["inputs"].compact.length < 1
        raise "subscribe input points are undefined"
      end
      @logger = Logger.new(options["logfile"])
      @sock ||= begin
        sock = @context.socket(ZMQ::SUB)
        @options["inputs"].each do |point|
          @logger.info("connecting to #{point}")
          sock.connect(point)
        end
        sock.setsockopt(ZMQ::LINGER, 100)
        sock
      end
    end

    def self.listen(filter=nil, &block)
      init unless @sock
      @sock.setsockopt(ZMQ::SUBSCRIBE, filter.to_s)

      Horobi.close_hooks do
        @input.close
        @context.close
      end

      loop do
        buf = @sock.recv(ZMQ::NOBLOCK)
        block.call(buf) if buf
        sleep 0.1
      end
    end
  end
end
