# -*- coding: utf-8 -*-
import xml.etree.ElementTree as ET

# Definición de coordenadas para un diseño limpio sin cruces
# Carriles:
# User Lane: y = -30 a 280 (Centro de tareas: y=120, PIN/Huella: y=40, Clear: y=200)
# App Lane: y = 280 a 600 (Centro de gateways: y=340, Procesos Online/Offline: y=450)
# Server Lane: y = 600 a 810 (Centro de Supabase: y=700)

shapes = {
    # Lane User
    "StartEvent_1": {"x": 170, "y": 120, "w": 36, "h": 36},
    "Task_FullLoginInput": {"x": 340, "y": 100, "w": 130, "h": 80},
    "Task_InputPIN": {"x": 620, "y": 30, "w": 120, "h": 80},
    "Gateway_PINCheck": {"x": 800, "y": 45, "w": 50, "h": 50},
    "Task_ProvideBiometrics": {"x": 920, "y": 30, "w": 120, "h": 80},
    "Gateway_BiometricCheck": {"x": 1100, "y": 45, "w": 50, "h": 50},
    "Task_ClearSession": {"x": 620, "y": 180, "w": 120, "h": 80},
    "Task_SetupPIN": {"x": 1250, "y": 100, "w": 130, "h": 80},
    "Task_SetupBiometrics": {"x": 1420, "y": 100, "w": 130, "h": 80},
    "EndEvent_Dashboard": {"x": 1650, "y": 120, "w": 36, "h": 36},
    
    # Lane App
    "Gateway_HasSession": {"x": 240, "y": 320, "w": 50, "h": 50},
    "Gateway_GracePeriod": {"x": 340, "y": 320, "w": 50, "h": 50},
    "Gateway_QuickAccessType": {"x": 480, "y": 320, "w": 50, "h": 50},
    "Task_UpdateTimestamp": {"x": 1255, "y": 305, "w": 120, "h": 80},
    "Gateway_NetworkCheck": {"x": 380, "y": 450, "w": 50, "h": 50},
    "Task_OnlineAuth": {"x": 490, "y": 400, "w": 120, "h": 80},
    "Gateway_OnlineAuthCheck": {"x": 650, "y": 415, "w": 50, "h": 50},
    "Task_OfflineAuth": {"x": 490, "y": 500, "w": 120, "h": 80},
    "Gateway_OfflineHashCheck": {"x": 650, "y": 515, "w": 50, "h": 50},
    "EndEvent_FailOfflineNoCache": {"x": 780, "y": 522, "w": 36, "h": 36},
    "Task_SaveSession": {"x": 1425, "y": 305, "w": 120, "h": 80},
    "DataStoreReference_SecureStorage": {"x": 1300, "y": 450, "w": 50, "h": 50},
    
    # Lane Server
    "Task_SupabaseAuth": {"x": 490, "y": 660, "w": 120, "h": 80},
    "DataStoreReference_Supabase": {"x": 650, "y": 675, "w": 50, "h": 50}
}

# Conexiones limpias y ortogonales (evitando cruces)
edges = {
    "Flow_Start": [
        (188, 156),
        (210, 156),
        (210, 345),
        (240, 345)
    ],
    "Flow_NoSession": [
        (265, 320),
        (265, 140),
        (340, 140)
    ],
    "Flow_HasSession": [
        (290, 345),
        (340, 345)
    ],
    "Flow_ToNetworkCheck": [
        (405, 180),
        (405, 450)
    ],
    "Flow_OnlinePath": [
        (405, 450),
        (405, 440),
        (490, 440)
    ],
    "Flow_OfflinePath": [
        (405, 500),
        (405, 540),
        (490, 540)
    ],
    "Flow_ToSupabase": [
        (550, 480),
        (550, 660)
    ],
    "Flow_FromSupabase": [
        (610, 700),
        (675, 700),
        (675, 465)
    ],
    "Flow_OnlineSuccess": [
        (700, 440),
        (1200, 440),
        (1200, 140),
        (1250, 140)
    ],
    "Flow_OnlineFailLoop": [
        (675, 415),
        (675, 230),
        (405, 230),
        (405, 180)
    ],
    "Flow_ToOfflineHashCheck": [
        (610, 540),
        (650, 540)
    ],
    "Flow_OfflineSuccess": [
        (700, 540),
        (1220, 540),
        (1220, 140),
        (1250, 140)
    ],
    "Flow_OfflineFailLoop": [
        (675, 565),
        (675, 580),
        (380, 580),
        (380, 180)
    ],
    "Flow_OfflineNoCache": [
        (675, 540),
        (780, 540)
    ],
    "Flow_ToSetupBiometrics": [
        (1380, 140),
        (1420, 140)
    ],
    "Flow_ToSaveSession": [
        (1485, 180),
        (1485, 305)
    ],
    "Flow_ToDashboardDirect": [
        (1545, 345),
        (1668, 345),
        (1668, 156)
    ],
    "Flow_GraceYes": [
        (365, 320),
        (365, 250),
        (1668, 250),
        (1668, 156)
    ],
    "Flow_GraceNo": [
        (390, 345),
        (480, 345)
    ],
    "Flow_PrefPIN": [
        (505, 320),
        (505, 70),
        (620, 70)
    ],
    "Flow_PrefBiometrics": [
        (530, 345),
        (890, 345),
        (890, 70),
        (920, 70)
    ],
    "Flow_ToPINCheck": [
        (740, 70),
        (800, 70)
    ],
    "Flow_PINSuccess": [
        (825, 95),
        (825, 325),
        (1255, 325)
    ],
    "Flow_PINFailLoop": [
        (825, 45),
        (825, 10),
        (680, 10),
        (680, 30)
    ],
    "Flow_PINForgot": [
        (825, 95),
        (825, 220),
        (740, 220)
    ],
    "Flow_ToBiometricCheck": [
        (1040, 70),
        (1100, 70)
    ],
    "Flow_BiometricSuccess": [
        (1125, 95),
        (1125, 345),
        (1255, 345)
    ],
    "Flow_BiometricFailLoop": [
        (1125, 45),
        (1125, 10),
        (980, 10),
        (980, 30)
    ],
    "Flow_BiometricForgot": [
        (1125, 95),
        (1125, 220),
        (740, 220)
    ],
    "Flow_ToDashboardAfterUpdate": [
        (1375, 345),
        (1668, 345),
        (1668, 156)
    ],
    "Flow_FromClearSession": [
        (620, 220),
        (405, 220),
        (405, 180)
    ]
}

# Leer archivo actual para no perder definiciones de procesos y flujos lógicos
bpmn_path = "/home/jhonataningesis/Documentos/Brismar/BRISMAR_APP/docs/brismar_brain/diagramas/FLUJO_01_AUTENTICACION.bpmn"

# Registrar namespaces para que ElementTree no genere prefijos raros
namespaces = {
    "bpmn": "http://www.omg.org/spec/BPMN/20100524/MODEL",
    "bpmndi": "http://www.omg.org/spec/BPMN/20100524/DI",
    "dc": "http://www.omg.org/spec/DD/20100524/DC",
    "di": "http://www.omg.org/spec/DD/20100524/DI"
}
for prefix, uri in namespaces.items():
    ET.register_namespace(prefix, uri)

tree = ET.parse(bpmn_path)
root = tree.getroot()

# Actualizar el diagrama visual
plane = root.find(".//bpmndi:BPMNPlane", namespaces)

# Limpiar formas y conectores actuales
for child in list(plane):
    plane.remove(child)

# Agregar participantes y carriles visuales
participant_id = "Participant_1"
participant_shape = ET.Element("bpmndi:BPMNShape", {
    "id": f"{participant_id}_di",
    "bpmnElement": participant_id,
    "isHorizontal": "true"
})
ET.SubElement(participant_shape, "dc:Bounds", {"x": "100", "y": "-50", "width": "1800", "height": "860"})
plane.append(participant_shape)

# Carriles
lanes = [
    ("Lane_User", -50, 330),
    ("Lane_App", 280, 320),
    ("Lane_Server", 600, 210)
]
for lane_id, y, h in lanes:
    lane_shape = ET.Element("bpmndi:BPMNShape", {
        "id": f"{lane_id}_di",
        "bpmnElement": lane_id,
        "isHorizontal": "true"
    })
    ET.SubElement(lane_shape, "dc:Bounds", {"x": "130", "y": str(y), "width": "1770", "height": str(h)})
    plane.append(lane_shape)

# Agregar las Formas con coordenadas perfectas
for element_id, coords in shapes.items():
    shape = ET.Element("bpmndi:BPMNShape", {
        "id": f"{element_id}_di",
        "bpmnElement": element_id
    })
    if "Gateway" in element_id or "StartEvent" in element_id or "EndEvent" in element_id:
        shape.set("isMarkerVisible", "true")
        
    ET.SubElement(shape, "dc:Bounds", {
        "x": str(coords["x"]),
        "y": str(coords["y"]),
        "width": str(coords["w"]),
        "height": str(coords["h"])
    })
    
    # Agregar etiquetas específicas para gateways y eventos
    if "Gateway" in element_id or "Event" in element_id:
        label = ET.SubElement(shape, "bpmndi:BPMNLabel")
        ET.SubElement(label, "dc:Bounds", {
            "x": str(coords["x"] - 20),
            "y": str(coords["y"] + coords["h"] + 5),
            "width": str(coords["w"] + 40),
            "height": "30"
        })
        
    plane.append(shape)

# Agregar los Conectores con waypoints ortogonales perfectos
for edge_id, waypoints in edges.items():
    edge = ET.Element("bpmndi:BPMNEdge", {
        "id": f"{edge_id}_di",
        "bpmnElement": edge_id
    })
    for wp in waypoints:
        ET.SubElement(edge, "di:waypoint", {"x": str(wp[0]), "y": str(wp[1])})
        
    # Añadir etiquetas de camino (Sí / No / PIN / Huella)
    flow_element = root.find(f".//bpmn:sequenceFlow[@id='{edge_id}']", namespaces)
    if flow_element is not None and "name" in flow_element.attrib:
        name = flow_element.attrib["name"]
        label = ET.SubElement(edge, "bpmndi:BPMNLabel")
        # Colocar la etiqueta cerca del primer punto del camino
        lx = waypoints[0][0] + 10
        ly = waypoints[0][1] - 15
        ET.SubElement(label, "dc:Bounds", {
            "x": str(lx),
            "y": str(ly),
            "width": "50",
            "height": "14"
        })
        
    plane.append(edge)

# Asociaciones de datos (Secure Storage & Supabase)
associations = [
    ("DataInputAssociation_OfflineRead", [(1300, 475), (550, 500)]),
    ("DataOutputAssociation_SaveSession", [(1485, 385), (1350, 475)]),
    ("DataOutputAssociation_UpdateTimestamp", [(1315, 385), (1325, 450)]),
    ("DataOutputAssociation_ClearSession", [(740, 220), (1300, 475)]),
    ("DataOutputAssociation_Supabase", [(610, 700), (650, 700)])
]
for assoc_id, waypoints in associations:
    edge = ET.Element("bpmndi:BPMNEdge", {
        "id": f"{assoc_id}_di",
        "bpmnElement": assoc_id
    })
    for wp in waypoints:
        ET.SubElement(edge, "di:waypoint", {"x": str(wp[0]), "y": str(wp[1])})
    plane.append(edge)

# Guardar de vuelta al archivo original
tree.write(bpmn_path, encoding="utf-8", xml_declaration=True)
print("BPMN visualmente autoordenado y regenerado con éxito.")
