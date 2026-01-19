import SwiftUI

struct CalendarSceneMain: View {
    let today = Date()
    
    @Environment(\.vars) var vars
    @Environment(\.calendar) var calendar

    // 示例任务数据
    let sampleTasks: [Models.Task] = [
        createSampleTask(title: "D", startHour: 4, startMinute: 0, endHour: 6, endMinute: 15, startDayOffset: 0),
        createSampleTask(title: "C", startHour: 4, startMinute: 0, endHour: 5, endMinute: 30, startDayOffset: 0),
        createSampleTask(title: "Apple", startHour: 4, startMinute: 15, endHour: 4, endMinute: 45, startDayOffset: 0),
        createSampleTask(title: "Banana", startHour: 4, startMinute: 45, endHour: 6, endMinute: 0, startDayOffset: 0),
        createSampleTask(title: "P", startHour: 5, startMinute: 45, endHour: 7, endMinute: 0, startDayOffset: 0),
        createSampleTask(title: "H", startHour: 5, startMinute: 45, endHour: 6, endMinute: 15, startDayOffset: 0),
        createSampleTask(title: "L", startHour: 6, startMinute: 30, endHour: 7, endMinute: 15, startDayOffset: 0),
        createSampleTask(title: "K", startHour: 7, startMinute: 45, endHour: 8, endMinute: 15, startDayOffset: 0),
        createSampleTask(title: "FF", startHour: 8, startMinute: 30, endHour: 10, endMinute: 0, startDayOffset: 0),
        createSampleTask(title: "应用", startHour: 9, startMinute: 30, endHour: 10, endMinute: 15, startDayOffset: 0),
        createSampleTask(title: "PP", startHour: 10, startMinute: 30, endHour: 11, endMinute: 0, startDayOffset: 0),
        
        
        createSampleTask(title: "A", startHour: 6, startMinute: 0, endHour: 7, endMinute: 15, startDayOffset: 1),
        createSampleTask(title: "B", startHour: 6, startMinute: 45, endHour: 9, endMinute: 45, startDayOffset: 1),
        createSampleTask(title: "C", startHour: 7, startMinute: 30, endHour: 9, endMinute: 0, startDayOffset: 1),
        createSampleTask(title: "D", startHour: 9, startMinute: 15, endHour: 10, endMinute: 0, startDayOffset: 1),
        createSampleTask(title: "E", startHour: 8, startMinute: 30, endHour: 10, endMinute: 15, startDayOffset: 1),
        createSampleTask(title: "A", startHour: 10, startMinute: 30, endHour: 12, endMinute: 0, startDayOffset: 1),
        createSampleTask(title: "B", startHour: 11, startMinute: 15, endHour: 12, endMinute: 15, startDayOffset: 1),
        createSampleTask(title: "C", startHour: 11, startMinute: 30, endHour: 12, endMinute: 30, startDayOffset: 1),
        
        createSampleTask(title: "和John沟通项目A 和项目B 如何继续推进并安排下一次的事情讨论", startHour: 4, startMinute: 30, endHour: 6, endMinute: 0, startDayOffset: 2),
        createSampleTask(title: "约下属谈话", startHour: 4, startMinute: 45, endHour: 5, endMinute: 45, startDayOffset: 2),
        createSampleTask(title: "暂时未定", startHour: 5, startMinute: 30, endHour: 6, endMinute: 45, startDayOffset: 2),
        createSampleTask(title: "no title", startHour: 10, startMinute: 15, endHour: 10, endMinute: 45, startDayOffset: 2),

        createSampleTask(title: "晨会", startHour: 4, startMinute: 30, endHour: 6, endMinute: 0, startDayOffset: 3),
        createSampleTask(title: "需求讨论", startHour: 5, startMinute: 15, endHour: 6, endMinute: 0, startDayOffset: 3),
        createSampleTask(title: "产品评审会", startHour: 5, startMinute: 30, endHour: 6, endMinute: 30, startDayOffset: 3),
        
        createSampleTask(title: "和Jack通电话", startHour: 4, startMinute: 15, endHour: 5, endMinute: 45, startDayOffset: 4),
        createSampleTask(title: "中途的事项", startHour: 5, startMinute: 15, endHour: 6, endMinute: 15, startDayOffset: 4),
        createSampleTask(title: "面试安排", startHour: 5, startMinute: 45, endHour: 6, endMinute: 15, startDayOffset: 4)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            CalendarSceneToolbar()
            CalendarSchedule(
                dates: calendar.schedule.dates,
                tasks: calendar.schedule.tasks,
                theme: vars.theme
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: goBack) {
                    Label("Back", systemImage: "arrow.left")
                }
            }
        }
    }
    
    private func goBack() {
        Modules.main.switch(scene: .projects)
    }
    
    static func createSampleTask(
        title: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        startDayOffset: Int
    ) -> Models.Task {
        let task = Models.Task(
            block: UUID(),
            parent: nil,
            project: nil,
            title: title,
            rank: "",
            type: .task
        )
        
        let calendar = Calendar.current
        let today = Date()
        
        // 设置开始时间
        if let startDate = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: today) {
            task.startAt = calendar.date(byAdding: .day, value: startDayOffset, to: startDate)
        }
        
        // 设置结束时间
        if let endDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: today) {
            task.endAt = calendar.date(byAdding: .day, value: startDayOffset, to: endDate)
        }
        
        return task
    }
}
