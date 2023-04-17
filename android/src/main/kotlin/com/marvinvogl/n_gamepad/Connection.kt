package com.marvinvogl.n_gamepad

import androidx.lifecycle.coroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetSocketAddress

class Connection(
    private val observer: GamepadObserver,
) {
    private lateinit var socket: DatagramSocket

    var address: InetSocketAddress? = null

    fun bind() {
        socket = DatagramSocket()
    }

    fun close() {
        socket.close()
    }

    fun send(buffer: ControlBuffer): Boolean {
        if (buffer.bitfield != 0) {
            send(buffer.array, buffer.length)
        }
        return true
    }

    private fun send(array: ByteArray, length: Int) {
        if (address != null) {
            val packet = DatagramPacket(array, length, address)

            if (!socket.isClosed) {
                observer.lifecycle.coroutineScope.launch {
                    send(packet)
                }
            }
        }
    }

    private suspend fun send(packet: DatagramPacket) = withContext(Dispatchers.IO) {
        socket.send(packet)
    }
}
