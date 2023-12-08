//  Created by Alessandro Comparini on 05/12/23.
//

import Foundation

import HomeUseCases

public protocol AddSchedulePresenterOutput: AnyObject {
    func successFetchListServices()
}

public class AddSchedulePresenterImpl: AddSchedulePresenter {
    public weak var outputDelegate: AddSchedulePresenterOutput?
    
    private var servicesPicker: [ServicesPickerPresenterDTO] = []
    private var daysDock: [DateDockPresenterDTO] = []
    private var hoursDock: [HourDockPresenterDTO] = []
    
    public enum DockID: String {
        case daysDock = "DAYS_DOCK"
        case hoursDock = "HOURS_DOCK"
    }
    
    public enum PickerID: String {
        case clientsPicker = "CLIENTS_PICKER"
        case servicesPicker = "SERVICES_PICKER"
    }
    
    private let weekend = [1,7]
    
    private let listServicesUseCase: ListServicesUseCase
    
    public init(listServicesUseCase: ListServicesUseCase) {
        self.listServicesUseCase = listServicesUseCase
    }
    
    
//  MARK: - PUBLIC AREA
    
    public func fetchServices(_ userIDAuth: String) {
        Task {
            do {
                let servicesDTO: [ServiceUseCaseDTO]? = try await listServicesUseCase.list(userIDAuth)
                
                guard let servicesDTO else {return}
                
                let servicesPicker = servicesDTO.map({ service in
                    ServicesPickerPresenterDTO(
                        id: service.id,
                        name: service.name,
                        duration: service.duration)
                })
//                self.servicesPicker.append(ServicesPickerPresenterDTO())
                self.servicesPicker.append(contentsOf: servicesPicker)
                
                successFetchListServices()
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    public func getService(_ index: Int) -> ServicesPickerPresenterDTO? {
        return servicesPicker[index]
    }
    
    public func fetchDayDock(_ year: Int, _ month: Int) {
        calculateDaysOfMonth(year: year, month: month)
    }
    
    public func fetchHourDock(_ year: Int, _ month: Int, _ day: Int) {
        calculateHoursOfDay()
    }

    public func getDayDock(_ index: Int) -> DateDockPresenterDTO? {
        return daysDock[index]
    }
    
    public func getHourDock(_ index: Int) -> HourDockPresenterDTO? {
        return hoursDock[index]
    }
    
    public func getDayWeekName(_ date: String) -> String? {
        guard let dayWeek = dayWeek(date) else { return nil }
        return dayWeekName(dayWeek)
    }
    
    public func getMonthName(_ date: Date? = nil) -> String {
        let calendar = Calendar.current
        guard let date = (date == nil) ? Date() : date else { return "" }
        let month = calendar.component(.month, from: date)
        return getMonthName(month)
    }
    
    public func getCurrentDate() -> (year: Int, month: Int, day: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        return (year, month, day)
    }
    
    public func numberOfRowsPicker(pickerID: PickerID) -> Int {
        switch pickerID {
            case .clientsPicker:
                return 2
                
            case .servicesPicker:
                return servicesPicker.count
        }
    }
    
    
    public func numberOfItemsDock(dockID: DockID) -> Int {
        switch dockID {
            case .daysDock:
                return daysDock.count
            
            case .hoursDock:
                return hoursDock.count
        }
    }
    
    public func sizeOfItemsDock(dockID: DockID) -> CGSize {
        switch dockID {
            case .daysDock:
                return CGSize(width: 55, height: 70)
            
            case .hoursDock:
                return CGSize(width: 100, height: 44)
        }
    }
    
    
//  MARK: - PRIVATE AREA
    
    private func getMonthName(_ month: Int) -> String {
        return [
            1: "Janeiro",
            2: "Fevereiro",
            3: "Março",
            4: "Abril",
            5: "Maio",
            6: "Junho",
            7: "Julho",
            8: "Agosto",
            9: "Setembro",
            10: "Outubro",
            11: "Novembro",
            12: "Dezembro"
        ][month] ?? ""
    }
    
    public func getMonthInt(_ monthPTBR: String) -> Int? {
        return [
            "janeiro": 1,
            "fevereiro": 2,
            "março": 3 ,
            "abril": 4 ,
            "maio": 5 ,
            "junho": 6 ,
            "julho": 7 ,
            "agosto": 8 ,
            "setembro": 9 ,
            "outubro": 10 ,
            "novembro": 11 ,
            "dezembro": 12
        ][monthPTBR.lowercased()]
    }
    
    private func dayWeekName(_ dayWeek: Int) -> String {
        return [
            1: "Domingo",
            2: "Segunda-feira",
            3: "Terça-feira",
            4: "Quarta-feira",
            5: "Quinta-feira",
            6: "Sexta-feira",
            7: "Sábado",
        ][dayWeek] ?? ""
    }
    
    private func dayWeek(_ date: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        guard let date = formatter.date(from: date ) else { return nil }
        
        let calendar = Calendar.current
        
        return calendar.component(.weekday, from: date)
    }
    
    private func calculateDaysOfMonth(year: Int, month: Int) {
        let calendar = Calendar.current
        
        let componentDate = DateComponents(
            year: year,
            month: month
        )
        
        guard let date = calendar.date(from: componentDate) else { return }
        
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return }
        
        for day in (1...range.count) {
            let dateString = "\(year)/\(month)/\(day)"
            
            guard let dayWeek = dayWeek(dateString) else { return }
            
            daysDock.append(DateDockPresenterDTO(
                day: "\(day)",
                month: "\(month)",
                year: "\(year)",
                dayWeek: "\(dayWeekName(dayWeek).prefix(3).uppercased() )",
                disabled: isDisableDay(day, dayWeek) )
            )
        }
        
    }
    
    private func calculateHoursOfDay() {
        let calendar = Calendar.current
        var currentDateComponents = DateComponents()
        currentDateComponents.hour = 8
        currentDateComponents.minute = 0
        
        guard let startDate = calendar.date(from: currentDateComponents) else { return }
        
        let endDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: startDate)!
        
        var currentDate = startDate
        let dateHourFormatter = DateFormatter()
        let dateMinuteFormatter = DateFormatter()
        dateHourFormatter.dateFormat = "HH"
        dateMinuteFormatter.dateFormat = "mm"
        
        while currentDate <= endDate {
            let formattedHour = dateHourFormatter.string(from: currentDate)
            let formattedMinute = dateMinuteFormatter.string(from: currentDate)
            currentDate = calendar.date(byAdding: .minute, value: 30, to: currentDate)!
            hoursDock.append(
                HourDockPresenterDTO(
                    hour: formattedHour,
                    minute: formattedMinute,
                    disabled: isDisableHour(formattedHour, formattedMinute) )
            )
        }
    }
    
    private func isDisableHour(_ hour: String, _ min: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "HH:mm"
        
        guard
            let hourCompare = formatter.date(from: "\(hour):\(min)"),
            let lunch1 = formatter.date(from: "12:00"),
            let lunch2 = formatter.date(from: "14:00") else { return false }
        
        return hourCompare >= lunch1 && hourCompare <= lunch2
    }
    
    private func isDisableDay(_ day: Int, _ dayWeek: Int) -> Bool {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: Date())
        return day < currentDay || weekend.contains(dayWeek)
    }
    
    
    
//  MARK: - MAIN THREAD AREA
    
    private func successFetchListServices() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            outputDelegate?.successFetchListServices()
        }
    }

}
