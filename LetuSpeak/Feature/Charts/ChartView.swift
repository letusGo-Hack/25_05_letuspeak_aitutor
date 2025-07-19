//
//  file.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import SwiftUI
import Charts

struct ProgressChartView: View {
    var body: some View {
        Chart3D {
            SurfacePlot(x: "X", y: "Y", z: "Z") { x, z in
                // (Double, Double) -> Double
                x * z
            }
        }
    }
}
