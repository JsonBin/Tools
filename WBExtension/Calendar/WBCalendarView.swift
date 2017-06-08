//
//  WBCalendarView.swift
//  WBAlamofire
//
//  Created by zwb on 2017/4/6.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

public typealias Manager = WBCalendarDateManager
public typealias CalendarView = WBCalendarView

/// 日历界面
open class WBCalendarView: UIView {

// MARK: - Open properties
    /// 一共能显示多少个月的日历, 默认为1年
    open var maxMonth: Int?
    /// 左右两边边距
    open var screenPadding: CGFloat = 0
    /// 回调
    open var delegate: WBCalendarViewProtocol?
    /// 正常状态下的字体颜色
    open var normalTextColor: UIColor = .black
    /// 选中字体的颜色
    open var selectTextColor: UIColor = .white
    /// 高亮区域字体颜色
    open var hightTextColor: UIColor = .lightGray
    /// 选中的背景颜色
    open var selectoBackgroundColor: UIColor = .red
    /// 高亮区域(选中区域)的背景颜色
    open var hightBackgroundColor: UIColor = .orange
    /// 标题栏和星期栏背景颜色
    open var titleBackgroundColor: UIColor = .white
    /// 标题栏和星期栏字体颜色
    open var titleTextColor: UIColor = .black
    /// 过去时间抛去的日期字体颜色
    open var lastTextColor: UIColor = .lightGray
    /// 是否只选择入住日期
    open var choseOnce: Bool = false
    /// 设置日历的背景颜色
    open var calendarBackgroundColor: UIColor = .white {
        didSet{
            if calendarBackgroundColor == oldValue { return }
            _calendarCollectionView.backgroundColor = calendarBackgroundColor
        }
    }
    
    public typealias calendarClosure = (_ start:String, _ end: String, _ stayCount: Int) -> Void
    public typealias calendarInClosure = (_ date: String) -> Void
    
// MARK: - Private properties
    public private(set) var _closure: calendarClosure?
    public private(set) var _onceClosure: calendarInClosure?
    // 入住日期
    open var _startIndexPath: IndexPath?
    // 离店日期
    open var _endIndexPath: IndexPath?
    
    private var _calendarCollectionView: UICollectionView!
    
    open private(set) var _monthWeeks = [Int]()
    open private(set) var _months = [String]()
    open private(set) var _days = [Int]()
    open private(set) var _weeks = [String]()
    open private(set) var _firstWeekDays = [Int]()
    
    /// 对数据初始化以及选择回调
    ///
    /// - Parameters:
    ///   - date1: 开始日期
    ///   - date2: 结束日期
    ///   - result: 选择回调结果
    open func calenderView(start date1: String?, end date2: String?, choose result: calendarClosure?) -> Void {
        _closure = result
        
        guard let date1 = date1, let date2 = date2 else { return }
        let calendar = Calendar.current
        let sets = Set<Calendar.Component>(arrayLiteral: .year, .month, .day)
        
        if let time1 = date1.calendarStringToDate(), let time2 = date2.calendarStringToDate() {
            let component1 = calendar.dateComponents(sets, from: time1)
            let component2 = calendar.dateComponents(sets, from: time2)
            
            // 找出开始和结束在第几个列表
            let dateString1 = "\(component1.year!)年\(component1.month!)月"
            let dateString2 = "\(component2.year!)年\(component2.month!)月"
            guard let startSection = _months.index(where: { $0 == dateString1 }) else {
                CalendarLogs("\(date1)月份不在所显示的日历范围内")
                return
            }
            guard let endSection = _months.index(where: { $0 == dateString2 }) else {
                CalendarLogs("\(date2)月份不在所显示的日历范围内")
                return
            }
            
            // 找出开始和结束的日期在第几天
            let startDay = component1.day!
            let endDay = component2.day!
            
            if startSection == 0 && startDay < Manager.expireDataCount() {
                CalendarLogs("\(date1)日期不在所显示的月份范围内")
                return
            }
            if endSection == 0 && endDay < Manager.expireDataCount() {
                CalendarLogs("\(date2)日期不在所显示的月份范围内")
                return
            }
            if startDay > _days[startSection] || endDay > _days[endSection] {
                CalendarLogs("\(date1)或\(date2)日期超出当前月份的范围")
                return
            }
            
            _startIndexPath = IndexPath(row: startDay + 5 + _firstWeekDays[startSection], section: startSection)
            _endIndexPath = IndexPath(row: endDay + 5 + _firstWeekDays[endSection], section: endSection)
            
           _calendarCollectionView.reloadData()
        }
    }
    
    // 只选择入住日期
    open func calendarOnceView(start date: String?, choose result: calendarInClosure?) -> Void {
        _onceClosure = result
        
        guard let date1 = date else { return }
        let calendar = Calendar.current
        let sets = Set<Calendar.Component>(arrayLiteral: .year, .month, .day)
        
        if let time = date1.calendarStringToDate(){
            let component = calendar.dateComponents(sets, from: time)
            
            // 找出开始和结束在第几个列表
            let dateString = "\(component.year!)年\(component.month!)月"
            guard let startSection = _months.index(where: { $0 == dateString }) else {
                CalendarLogs("\(date1)月份不在所显示的日历范围内")
                return
            }
            
            // 找出开始和结束的日期在第几天
            let startDay = component.day!
            
            if startSection == 0 && startDay < Manager.expireDataCount() {
                CalendarLogs("\(date1)日期不在所显示的月份范围内")
                return
            }
            _startIndexPath = IndexPath(row: startDay + 5 + _firstWeekDays[startSection], section: startSection)
            _calendarCollectionView.reloadData()
        }
    }
    
// MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeData()
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeData()
        setUp()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _calendarCollectionView.frame = bounds
    }
    
    private func setUp() {
        backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        _calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _calendarCollectionView.backgroundColor = calendarBackgroundColor
        _calendarCollectionView.delegate = self
        _calendarCollectionView.dataSource = self
        _calendarCollectionView.register(CalenderCell.self, forCellWithReuseIdentifier: WBCalendarCollectionViewCell)
        _calendarCollectionView.register(CalenderHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: WBCalendarCollectionViewHeader)
        addSubview(_calendarCollectionView)
    }
    
    private func initializeData() {
        _weeks = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        
        maxMonth = maxMonth ?? 12
        
        let manager = Manager(maxMonths: maxMonth!)
        _months = manager.monthWithYears()
        _monthWeeks = manager.calculateInfoWithMonth(.weekOfMonth)
        _days = manager.calculateInfoWithMonth(.day)
        _firstWeekDays = manager.calculateFirstDayOfWeekInMonth()
    }
}
private let WBCalendarCollectionViewCell = "WBCalendarCollectionViewCell"
private let WBCalendarCollectionViewHeader = "WBCalendarCollectionViewHeader"

/// 选择日期回调
public protocol WBCalendarViewProtocol {
    /// 选择日期的回调
    ///
    /// - Parameters:
    ///   - date1: 入住日期
    ///   - date2: 离开日期
    ///   - count: 停留天数
    func calendarView(start date1:String, end date2:String, choose count: Int) -> Void
    
    /// 只选择入住回调
    ///
    /// - Parameter date: 入住日期
    func calendarOnceView(_ date: String) -> Void
}

// MARK: - UICollectionViewDelegate
extension WBCalendarView : UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstWeek = 5 + _firstWeekDays[indexPath.section]
        // 过期时间直接抛去
        if indexPath.section == 0 && indexPath.row < firstWeek + Manager.expireDataCount() + 1{ return }
        // 设置范围内点击才有效
        if indexPath.row < firstWeek + 1 || indexPath.row > firstWeek + _days[indexPath.section] { return }
        if choseOnce { // 只选择入住日期
            _startIndexPath = indexPath
            // 可回调结果
            let date = (_months[indexPath.section] + "\(indexPath.row - firstWeek)日")/*.unityFormattedString()*/
            
            // closure
            if let closure = _onceClosure {
                closure(date)
            }
            // delegate
            if let delegate = delegate {
                delegate.calendarOnceView(date)
            }
            collectionView.reloadData()
            return
        }
        // 存在入住
        if let start = _startIndexPath {
            // 存在离店
            if let end = _endIndexPath {
                // 选择入住和离店之间为离店
                if indexPath < end && indexPath > start {
                    _endIndexPath = indexPath
                    // 可回调结果
                    let startDateString = (_months[start.section] + "\(start.row - 5 - _firstWeekDays[start.section])日")/*.unityFormattedString()*/
                    let endDateString = (_months[_endIndexPath!.section] + "\(_endIndexPath!.row - firstWeek)日")/*.unityFormattedString()*/
                    let startDate = startDateString.calendarStringToDate()
                    let endDate = endDateString.calendarStringToDate()
                    let count = Manager.compare(startDate, to: endDate)
                    
                    // closure
                    if let closure = _closure {
                        closure(startDateString, endDateString, count)
                    }
                    // delegate
                    if let delegate = delegate {
                        delegate.calendarView(start: startDateString, end: endDateString, choose: count)
                    }
                    
                }else{
                    // 其他选择为重新入住并重设离店
                    _startIndexPath = indexPath
                    _endIndexPath = nil
                }
            }else{
                // 没有离店，选择比较小为重新入住
                if indexPath < start {
                    _startIndexPath = indexPath
                    _endIndexPath = nil
                }else{
                    // 选择为离店
                    _endIndexPath = indexPath
                    // 可回调结果
                    let startDateString = (_months[start.section] + "\(start.row - 5 - _firstWeekDays[start.section])日")/*.unityFormattedString()*/
                    let endDateString = (_months[_endIndexPath!.section] + "\(_endIndexPath!.row - firstWeek)日")/*.unityFormattedString()*/
                    let startDate = startDateString.calendarStringToDate()
                    let endDate = endDateString.calendarStringToDate()
                    let count = Manager.compare(startDate, to: endDate)
                    
                    // closure
                    if let closure = _closure {
                        closure(startDateString, endDateString, count)
                    }
                    // delegate
                    if let delegate = delegate {
                        delegate.calendarView(start: startDateString, end: endDateString, choose: count)
                    }
                }
            }
        }else{
            // 重新设置入住
            _startIndexPath = indexPath
            _endIndexPath = nil
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WBCalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frame.size.width - screenPadding * 2
        let layoutH = (width / 7) > 44 ? 44 : (width / 7)
        return CGSize(width: width / 7, height: layoutH)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, screenPadding, 0, screenPadding)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: frame.size.width, height: 44)
    }
}

// MARK: - UICollectionViewDataSource
extension WBCalendarView : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return maxMonth!
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (_monthWeeks[section] + 1 ) * 7
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WBCalendarCollectionViewCell, for: indexPath) as! CalenderCell
        cell.textLabel?.textColor = normalTextColor
        cell.detailLabel?.textColor = normalTextColor
        if indexPath.row < 7 {
            // 设置顶部week
            cell.contentView.backgroundColor = titleBackgroundColor
            cell.textLabel?.textColor = titleTextColor
            cell.textLabel?.text = _weeks[indexPath.row]
            cell.detailLabel?.text = nil
        }else{
            cell.contentView.backgroundColor = .clear
            let firstWeek = 6 + _firstWeekDays[indexPath.section] - 1
            if indexPath.row > firstWeek && indexPath.row <= firstWeek + _days[indexPath.section] {
                cell.textLabel?.text = "\(indexPath.row - firstWeek)"
                cell.detailLabel?.text = nil
                if firstWeek == 1 && indexPath.row > firstWeek + _days[indexPath.section] {
                    cell.textLabel?.text = nil
                    cell.detailLabel?.text = nil
                }else{
                    cell.textLabel?.text = "\(indexPath.row - firstWeek)"
                    cell.detailLabel?.text = nil
                }
                
                // change textColor
                if indexPath.section == 0 {
                    if indexPath.row <= firstWeek + Manager.expireDataCount(){
                        cell.textLabel?.textColor = lastTextColor
                        cell.detailLabel?.textColor = lastTextColor
                    }
                    else if indexPath.row == firstWeek + Manager.expireDataCount() + 1 {
                        cell.textLabel?.text = "今天"
                        cell.detailLabel?.text = nil
                    }else if indexPath.row == firstWeek + Manager.expireDataCount() + 2 {
                        cell.textLabel?.text = "明天"
                        cell.detailLabel?.text = nil
                    }else if indexPath.row == firstWeek + Manager.expireDataCount() + 3 {
                        cell.textLabel?.text = "后天"
                        cell.detailLabel?.text = nil
                    }
                }
                
                // 设置选中的区域段
                if let startIndexPath = _startIndexPath, let endIndexPath = _endIndexPath {
                    if indexPath < endIndexPath && indexPath > startIndexPath {
                        cell.contentView.backgroundColor = hightBackgroundColor
                        cell.textLabel?.textColor = hightTextColor
                        cell.detailLabel?.text = nil
                    }else{
                        // 设置第一月已过日期不能点击
                        if indexPath.section == 0 && indexPath.row <= firstWeek + Manager.expireDataCount() {
                            cell.textLabel?.textColor = lastTextColor
                            cell.detailLabel?.textColor = lastTextColor
                        }else{
                            cell.textLabel?.textColor = normalTextColor
                        }
                    }
                }else{
                    // 设置第一月已过日期不能点击
                    if indexPath.section == 0 && indexPath.row <= firstWeek + Manager.expireDataCount() {
                        cell.textLabel?.textColor = lastTextColor
                        cell.detailLabel?.textColor = lastTextColor
                    }else{
                        cell.textLabel?.textColor = normalTextColor
                    }
                }
                // 设置选中的开始
                if let startIndexPath = _startIndexPath, startIndexPath == indexPath {
                    cell.detailLabel?.text = "入住"
                    cell.contentView.backgroundColor = selectoBackgroundColor
                    cell.textLabel?.textColor = selectTextColor
                    cell.detailLabel?.textColor = selectTextColor
                }
                // 设置选中的结束
                if let endIndexPath = _endIndexPath, endIndexPath == indexPath {
                    cell.detailLabel?.text = "离店"
                    cell.contentView.backgroundColor = selectoBackgroundColor
                    cell.textLabel?.textColor = selectTextColor
                    cell.detailLabel?.textColor = selectTextColor
                }
            }else{
                cell.textLabel?.text = nil
                cell.detailLabel?.text = nil
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: WBCalendarCollectionViewHeader, for: indexPath) as! CalenderHeaderView
        headerView.textLabel?.text = _months[indexPath.section]
        headerView.textLabel?.backgroundColor = titleBackgroundColor
        headerView.textLabel?.textColor = titleTextColor
        return headerView
    }
}


// MARK: - UICollectionView Cell 
open class CalenderCell: UICollectionViewCell {
    
    var textLabel: YYLabel?
    var detailLabel: YYLabel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp() {

        textLabel = YYLabel()
        textLabel?.textAlignment = .center
        textLabel?.textColor = .black
        contentView.addSubview(textLabel!)
        
        detailLabel = YYLabel()
        detailLabel?.textAlignment = .center
        detailLabel?.textColor = .black
        contentView.addSubview(detailLabel!)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.frame.size.width
        let height = contentView.frame.size.height
        textLabel?.font = .systemFont(ofSize: 14 * width / 320 * 7)
        textLabel?.frame = CGRect(x: 0, y: 0, width: width, height: height / 3 * 2)
        
        detailLabel?.font = .systemFont(ofSize: 8 * width / 320 * 7)
        detailLabel?.frame = CGRect(x: 0, y: height / 3 * 2, width: width, height: height / 3)
    }
}


// MARK: - UICollectionView ReusableView
open class CalenderHeaderView: UICollectionReusableView {
    
    var textLabel: UILabel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeUI()
    }
    
    private func initializeUI() {
        textLabel = UILabel()
        textLabel?.backgroundColor = Color.Calendar.themBg
        textLabel?.textColor = .white
        textLabel?.textAlignment = .center
        addSubview(textLabel!)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.font = .systemFont(ofSize: 15 * frame.size.width / 320)
        textLabel?.frame = bounds
    }
}
