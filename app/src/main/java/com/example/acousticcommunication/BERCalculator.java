package com.example.acousticcommunication;


public class BERCalculator {
    static public boolean[] dataDecode;
    static public boolean[] dataEncode;
    static public int dataLength;
    static public long timeStart;
    static public long timeEnd;
    static public double demodulateSpeed;

    public static double getDemodulateSpeed() {
        return demodulateSpeed;
    }

    public static void setTimeStart(long timeStart) {
        BERCalculator.timeStart = timeStart;
    }

    public static void setTimeEnd(long timeEnd) {
        BERCalculator.timeEnd = timeEnd;
    }

    public static int getDataLength() {
        return dataLength;
    }

    public static void setDataEncode(boolean[] dataEncode) {
        int len = dataEncode.length;
        BERCalculator.dataEncode = new boolean[len];
        for(int i = 0; i < len; i++)
            BERCalculator.dataEncode[i] = dataEncode[i];
    }

    public static void setDataDecode(boolean[] dataDecode) {
        int len = dataDecode.length;
        BERCalculator.dataDecode = new boolean[len];
        for(int i = 0; i < len; i++)
            BERCalculator.dataDecode[i] = dataDecode[i];
    }

    public static double calculateBER() {
        dataLength = dataEncode.length;
        if(dataLength > dataDecode.length)
            dataLength = dataDecode.length;
        double errorBitQuantity = 0;
        for(int i = 0; i < dataLength; i++) {
            if(dataDecode[i] != dataEncode[i]) {
                errorBitQuantity += 1.0;
            }
        }
        demodulateSpeed = (dataLength - errorBitQuantity) / (timeEnd - timeStart) * 1000;
        double ber = errorBitQuantity / dataLength;
        return ber;
    }
}
