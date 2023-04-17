@file:Suppress("PLATFORM_CLASS_MAPPED_TO_KOTLIN")

package com.marvinvogl.n_gamepad

import java.lang.Float

class ControlBuffer(size: Int) {
    private val buffer = ByteArray(size + 1)
    private var offset = 1

    var bitfield = 0

    val array: ByteArray
        get() {
            buffer[0] = bitfield.toByte()
            bitfield = 0
            return buffer
        }

    val length: Int
        get() {
            val temp = offset
            offset = 1
            return temp
        }

    fun putCharData(data: Char) {
        buffer[offset++] = data.code.toByte()
    }

    fun putIntData(data: IntArray) {
        for (int in data) {
            buffer[offset++] = int.toByte()
        }
    }

    fun putFloatData(data: FloatArray) {
        for (float in data) {
            var bits = Float.floatToIntBits(float)

            buffer[offset++] = (bits shr 24).toByte()
            buffer[offset++] = (bits shr 16).toByte()
            buffer[offset++] = (bits shr 8).toByte()
            buffer[offset++] = bits.toByte()
        }
    }
}
