//import SwiftUI
//
//struct TasksSceneRootView: View {
//    @EnvironmentObject var tasks: Modules.Tasks
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            if let project = tasks.currentProject {
//                TasksSceneHeader(project: project)
//            }
//
//            ScrollView(.vertical) {
//                ForEach(tasks.currentProject.blocks) { block in
//                    TasksOmniBlock(data: block)
//                }
//                .padding(.horizontal)
//            }
//        }
//        .frame(idealWidth: 800, maxWidth: .infinity, idealHeight: 800, maxHeight: .infinity, alignment: .topLeading)
//    }
//    
//    func createBlock() {
//        
//    }
//}
