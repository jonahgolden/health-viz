red <- colorRampPalette(c("#FBE1D4", "#8F1919"))(7)
blue <- colorRampPalette(c("#CAD9EC", "#1A468F"))(6)
purple <- colorRampPalette(c("#BCBDDB", "#6A51A3"))(6)
green <- colorRampPalette(c("#C1E1B5", "#43884E"))(3)

BAR_PALETTE = c("HIV/AIDS & STIs"=red[1],
                "Respiratory infections &TB"=red[2],
                "Enteric infections"=red[3],
                "NTDs & malaria"=red[4],
                "Other infectious"=red[5],
                "Maternal & neonatal"=red[6],
                "Nutritional deficiencies"=red[7],
                "Neoplasms"=blue[1],
                "Cardiovascular diseases"=blue[2],
                "Chronic respiratory"=blue[3],
                "Digestive diseases"=blue[4],
                "Neurological disorders"=blue[5],
                "Mental disorders"=blue[6],
                "Substance use"=purple[1],
                "Diabetes & CKD"=purple[2],
                "Skin diseases"=purple[3],
                "Sense organ diseases"=purple[4],
                "Musculoskeletal disorders"=purple[5],
                "Other non-communicable"=purple[6],
                "Transport injuries"=green[1],
                "Unintentional injuries"=green[2],
                "Self-harm & violence"=green[3])