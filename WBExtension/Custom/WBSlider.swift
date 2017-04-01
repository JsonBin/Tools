//
//  WBSlider.swift
//  WBExtension
//
//  Created by zwb on 17/2/8.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: -  自定义Slider(视频、音频播放采用)

/// 自定义视频、音频滑条
open class WBSlider: UIControl {
    
    /// slider默认属性
    public struct SliderHeight{
        // 设置按钮的大小高度
        public static let buttonHeight:CGFloat = 16.0
        // 设置slider的高度
        public static let height:CGFloat = 3.0
    }
    
    /// slider delegate
    open var delegate:WBSliderDelegate?
    
    /// 当前进度 default 0.0.
    open var value:CGFloat!
        {
        didSet{
            layoutSubviews()
            minimumTrackViewWidth = maximumTrackView.frame.size.width*value
            sliderButtonCenterX = maximumTrackView.frame.origin.x+minimumTrackViewWidth
            layoutSubviews()
        }
    }
    
    /// 最小值 default 0.0.
    open var minimumValue:CGFloat!
    
    /// 最大值 default 1.0.
    open var maximumValue:CGFloat!
    
    /// 缓存进度值.
    open var cacheValue:CGFloat!{
        didSet{
            layoutSubviews()
            cacheTrackViewWidth = maximumTrackView.frame.size.width*cacheValue
            layoutSubviews()
        }
    }
    
    /// 当前进度条颜色 default orange.
    open var minimumTrackTintColor:UIColor!
        {
        didSet{ minimumTrackView.backgroundColor = minimumTrackTintColor }
    }
    
    /// 缓存进度条颜色 default gray.
    open var cacheTrackTintColor:UIColor!
        {
        didSet{ cacheTrackView.backgroundColor = cacheTrackTintColor }
    }
    
    /// 总进度条颜色 default lightGray.
    open var maximumTrackTintColor:UIColor!
        {
        didSet{ maximumTrackView.backgroundColor = maximumTrackTintColor }
    }
    
    /// 拖拽的thumb图片
    open var thumbImage:UIImage!
        {
        didSet{ setThumbImage(thumbImage, forState: .normal) }
    }
    
    // - private
    
    /// 已播放的进度条
    private lazy var minimumTrackView:UIView = {
        return UIView()
    }()
    /// 总进度条
    private lazy var maximumTrackView:UIView = {
        return UIView()
    }()
    /// 缓存的进度条
    private lazy var cacheTrackView:UIView = {
        return UIView()
    }()
    /// 滑动按钮
    private lazy var sliderButton: WBSliderButton = {
        let button = WBSliderButton(type: .custom)
        button.addTarget(self, action: #selector(beginSliderScrubbing(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(endSliderScrubbint(_:)), for: .touchCancel)
        button.addTarget(self, action: #selector(dragMoving(_:withEvent:)), for: .touchDragInside)
        button.addTarget(self, action: #selector(endSliderScrubbint(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(endSliderScrubbint(_:)), for: .touchUpOutside)
        return button
    }()
    /// 记录最小的播放进度宽度
    private var minimumTrackViewWidth:CGFloat = 0.0
    /// 记录缓存的进度宽度
    private var cacheTrackViewWidth:CGFloat = 0.0
    /// 滑动按钮的x坐标
    private var sliderButtonCenterX:CGFloat!
    /// 上次滑动的中心的
    private var lastPoint:CGPoint!
    
    /// init 初始化
    ///
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initWithSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initWithSubviews()
    }
    
    // MARK: - Init
    
    /// 初始化数据
    private func initWithSubviews() {
        addSubview(maximumTrackView)
        addSubview(cacheTrackView)
        addSubview(minimumTrackView)
        addSubview(sliderButton)
        
        // set defaultValue
        value = 0.0
        minimumValue = 0.0
        maximumValue = 1.0
        backgroundColor = .clear
        minimumTrackView.backgroundColor = .orange
        maximumTrackView.backgroundColor = .lightGray
        cacheTrackView.backgroundColor = .gray
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let trackViewX = SliderHeight.buttonHeight / 2
        let trackViewY = (frame.size.height - SliderHeight.height) / 2
        let trackViewWidth = frame.size.width - SliderHeight.buttonHeight
        maximumTrackView.frame = CGRect(x: trackViewX,
                                      y: trackViewY,
                                      width: trackViewWidth,
                                      height: SliderHeight.height)
        minimumTrackView.frame = CGRect(x: trackViewX,
                                      y: trackViewY,
                                      width: minimumTrackViewWidth,
                                      height: SliderHeight.height)
        cacheTrackView.frame = CGRect(x: trackViewX,
                                    y: trackViewY,
                                    width: cacheTrackViewWidth,
                                    height: SliderHeight.height)
        sliderButton.frame = CGRect(x: 0,
                                  y: trackViewY,
                                  width: frame.size.height,
                                  height: frame.size.height)
        var scenter = sliderButton.center
        scenter.x = sliderButtonCenterX ?? maximumTrackView.frame.origin.x
        scenter.y = minimumTrackView.center.y
        sliderButton.center = scenter
        lastPoint = scenter
    }
    
    
    /// 设置value
    ///
    /// - Parameter va: 需要设置的value
    open func setValue(_ va:CGFloat){
        
        value = va
        layoutSubviews()
        let finishValue = maximumTrackView.frame.size.width * va
        var temPoint = sliderButton.center
        temPoint.x = maximumTrackView.frame.origin.x + finishValue
        
        if temPoint.x >= maximumTrackView.frame.origin.x &&
            temPoint.x <= (frame.size.width - SliderHeight.buttonHeight / 2) {
            lastPoint = temPoint
            // 记录
            sliderButtonCenterX = temPoint.x
            minimumTrackViewWidth = temPoint.x
            // 重新布局
            layoutSubviews()
        }
        if temPoint.x <= maximumTrackView.frame.origin.x{
            if let minimumValue = minimumValue {
                value = minimumValue
            }else{
                value = 0.0
            }
        }else if temPoint.x >= (frame.size.width - SliderHeight.buttonHeight / 2) {
            if let maximumValue = maximumValue {
                value = maximumValue
            }else{
                value = 1.0
            }
        }
    }
    
    // MARK: - Event
    
    /// 开始拖动
    ///
    /// - Parameter button: 按住的button
    @objc private func beginSliderScrubbing(_ button:WBSliderButton) {
        delegate?.beginSlid(self, sliderButton: button)
    }
    
    /// 结束拖动
    ///
    /// - Parameter button: 按住的button
    @objc private func endSliderScrubbint(_ button:WBSliderButton) {
        delegate?.endSlide(self, sliderButton: button)
    }
    
    /// 正在拖动响应
    ///
    /// - Parameters:
    ///   - button: 拖动的butto
    ///   - event: 点击事件
    @objc private func dragMoving(_ button:WBSliderButton, withEvent event:UIEvent) {
        if let point = event.allTouches?.first?.location(in: self) {
            let offsetX = point.x - lastPoint.x
            let temPoint = CGPoint(x: button.center.x + offsetX, y: button.center.y)
            
            // 获取进度值
            let progressValue = (temPoint.x - maximumTrackView.frame.origin.x) * 1.0 / maximumTrackView.frame.size.width
            setValue(progressValue)
        }
        
        delegate?.sliding(self, sliderButton: button)
    }
    
    /// 设置按钮的背景图
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - state: 状态
    private func setThumbImage(_ image:UIImage, forState state:UIControlState) {
        thumbImage = image
        sliderButton.iconImageView.image = image
    }
}

// MARK: - Button

/// 自定义滑条滑动按钮
public class WBSliderButton: UIButton{
    
    /// 按钮的背景图
    public var iconImageView: UIImageView!
    
    /// init
    ///
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addImage()
    }
    
    /// 添加图片
    private func addImage() {
        iconImageView = UIImageView()
        iconImageView.backgroundColor = .white
        iconImageView.layer.cornerRadius = WBSlider.SliderHeight.buttonHeight / 2
        iconImageView.layer.masksToBounds = true
        addSubview(iconImageView)
        
        layoutSubviews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.frame = CGRect(x: (frame.size.width - WBSlider.SliderHeight.buttonHeight) / 2,
                                   y: (frame.size.height - WBSlider.SliderHeight.buttonHeight) / 2,
                                   width: WBSlider.SliderHeight.buttonHeight,
                                   height: WBSlider.SliderHeight.buttonHeight)
    }
}


// MARK: - Delegate

/// WBSlider 响应的delegate
public protocol WBSliderDelegate {
    
    @available(iOS 8.0, *)
    /// WBSlider开始拖动响应
    ///
    /// - Parameters:
    ///   - slider: slider
    ///   - sender: button
    func beginSlid(_ slider:WBSlider, sliderButton sender:WBSliderButton)
    
    @available(iOS 8.0, *)
    /// WBSlider正在拖动响应
    ///
    /// - Parameters:
    ///   - slider: slider
    ///   - sender: button
    func sliding(_ slider:WBSlider, sliderButton sender:WBSliderButton)
    
    @available(iOS 8.0, *)
    /// WBSlider结束拖动响应
    ///
    /// - Parameters:
    ///   - slider: slider
    ///   - sender: button
    func endSlide(_ slider:WBSlider, sliderButton sender:WBSliderButton)
}

