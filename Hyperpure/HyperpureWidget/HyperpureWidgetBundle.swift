// HyperpureWidgetBundle.swift
import WidgetKit
import SwiftUI

@main
struct HyperpureWidgetBundle: WidgetBundle {
    var body: some Widget {
        KitchenStatusWidget()
        DeliveryTrackingLiveActivity()
    }
}
