package org.hylly.mtk2garmin;

import it.unimi.dsi.fastutil.longs.Long2ObjectOpenHashMap;

import java.io.File;
import java.io.IOException;

public class OSMPBFWriter {

    private final File outFile;
    private final OSMPBF op;

    OSMPBFWriter(File outFile) {
        this.outFile = outFile;
        op = new OSMPBF(this.outFile);
    }

    void startWritingOSMPBF() throws IOException {
        op.writePBFHeaders();
    }

    void writeOSMPBFElements(StringTable stringtable, Long2ObjectOpenHashMap<LightNode> nodes, Long2ObjectOpenHashMap<LightWay> ways, Long2ObjectOpenHashMap<LightRelation> relations) throws IOException {
        op.writePBFElements(stringtable, nodes, null, null);
        op.writePBFElements(stringtable, null, ways, null);
        op.writePBFElements(stringtable, null, null, relations);

        // this.initElements();
    }

    void closeOSMPBFFile() throws IOException {
        op.closePBF();
    }
}
