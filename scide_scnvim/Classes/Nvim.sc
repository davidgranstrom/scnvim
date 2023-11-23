Nvim {
    var socket;
    classvar messageId = 0;

    *new {
        ^super.new.init;
    }

    init {
        socket = NetAddr("127.0.0.1", SCNvim.port);
        // socket.tryConnectTCP({
        //     "connected!".postln;
        // }, {
        //     "failed, re-trying..".postln;
        // });
    }

    attach {arg port, responseCallback;
        var bytes, count = 0;
        if (thisProcess.openPorts.includes(port).not) {
            thisProcess.openUDPPort(port, \raw);
            thisProcess.addRawRecvFunc({arg msg;
                var response, chunkId, numChunks;
                msg = msg.ascii.wrap(0, 255);
                response = MessagePack.decode(msg);
                chunkId = response[0];
                numChunks = response[1];
                if (count == 0) {
                    bytes = Array.newClear(numChunks);
                };
                count = count + 1;
                bytes[chunkId - 1] = response[2];
                if (count == numChunks) {
                    response = MessagePack.decode(bytes.join.ascii.wrap(0, 255));
                    count = 0;
                    bytes = nil;
                    if (responseCallback.notNil) {
                        responseCallback.(response);
                    };
                }
            });
        };
    }

    send {arg bytes;
        socket.sendRaw(bytes);
    }
}
