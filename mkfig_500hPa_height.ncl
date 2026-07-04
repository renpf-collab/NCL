; =====================================================================
; mkfig_500hPa_height.ncl - 500hPa位势高度 + 关键线加粗 + 风矢量（风羽）
; 绘制2026年5月19日12时（UTC）
; =============================================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-------------------- 固定时次 --------------------
year  = "2026"
mon   = "05"
day   = "19"
hour  = 12
level = 500
;-------------------------------------------------

; 读ERA5数据
f  = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/geopotential/" + "era5.geopotential." + year + mon + day + ".nc", "r")
f2 = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/u_component_of_wind/" + "era5.u_component_of_wind." + year + mon + day + ".nc", "r")
f3 = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/v_component_of_wind/" + "era5.v_component_of_wind." + year + mon + day + ".nc", "r")

u1 = f2->u(hour,{level},:,:)
v1 = f3->v(hour,{level},:,:)
wind_u = u1
wind_v = v1
uv_speed = wind_speed(wind_u, wind_v)

height = f->z(hour,{level},:,:)
hgt = height / 98
lat = f->latitude
lon = f->longitude

copy_VarCoords(height, hgt)

;----------------------------------------------------------------------
png_name = "./figures/Figure5b"
wks = gsn_open_wks("eps", png_name)

;-- 地图参数 ----------------------------------------------------------------
res = True
res@gsnDraw  = False
res@gsnFrame = False

res@mpMinLatF = 0.0
res@mpMaxLatF = 56.0
res@mpMinLonF = 70.0
res@mpMaxLonF = 137.0

res@mpProjection  = "LambertEqualArea"
res@mpLimitMode   = "LatLon"
res@mpCenterLatF  = (res@mpMinLatF+res@mpMaxLatF)/2.
res@mpCenterLonF  = (res@mpMinLonF+res@mpMaxLonF)/2.

res@vpWidthF    = 0.6
res@vpHeightF   = 0.4
res@mpShapeMode = "FreeAspect"


res@mpOutlineOn                 = True
res@mpGeophysicalLineColor      = "gray"
res@mpGeophysicalLineThicknessF = 1.
res@mpNationalLineColor         = "gray"
res@mpNationalLineThicknessF    = 1

res@mpFillOn              = False
res@mpDataBaseVersion     = "MediumRes"
res@mpDataSetName         = "Earth..4"
res@mpOutlineSpecifiers   = (/"China","China:states"/)
res@mpProvincialLineThicknessF = 1.
res@gsnAddCyclic          = False


; 坐标刻度
res@tmXTOn = False
res@tmYROn = False
res@pmTickMarkDisplayMode = "Always"

res@tmXBMajorLengthF        = 0.008
res@tmXBMajorOutwardLengthF = 0.008
res@tmXBMajorThicknessF     = 3
res@tmXBMinorLengthF        = 0
res@tmXBLabelDeltaF         = -0.6
res@tmXBLabelFontHeightF    = 0.011

res@tmYLLabelDeltaF      = -0.7
res@tmYLLabelFontHeightF = 0.011
res@tmYLMajorLengthF     = 0.008
res@tmYLMinorLengthF     = 0
res@tmYLMajorThicknessF  = 3

; 等值线 -- 基本
res@cnLinesOn            = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels             = (/488,492,496,500,504,508,512,516,520,524,528,532,536,540,544,548,552,556,560,564,568,572,576,580,584,588,592/)
res@cnLineColor          = "black"
res@cnLineThicknessF     = 2.0
res@cnLineLabelsOn       = True
res@cnLabelDrawOrder     = "PostDraw"
res@cnLineLabelFontHeightF       = 0.0090
res@cnLineLabelDensityF  = 1
res@cnLineLabelInterval  = 1.5
res@cnLineDrawOrder      = "Postdraw"
res@cnInfoLabelOn        = False
res@cnFillOn             = False
res@lbLabelBarOn         = False
res@cnFillOpacityF       = 0.7
res@cnLineLabelBackgroundColor  = "white"

; 空间平滑
hgt1 = hgt
wrf_smooth_2d(hgt1, 10)

plot = gsn_csm_contour_map(wks, hgt1, res)

; ========== 540/556/572/586 线加粗 ==========
res1 = True
res1@gsnDraw       = False
res1@gsnFrame      = False
res1@cnLinesOn     = True
res1@cnFillOn      = False
res1@cnLevelSelectionMode = "ExplicitLevels"
res1@cnLevels             = (/540, 556, 572, 586/)
res1@cnLineColor          = "black"
res1@cnLineThicknessF     = 2.0
res1@cnLineLabelsOn       = False
res1@cnInfoLabelOn        = False
res1@lbLabelBarOn         = False
res1@cnFillDrawOrder      = "PreDraw"
plot1 = gsn_csm_contour(wks, hgt1, res1)
res1@gsnShadeHigh = "yellow"
plot1 = gsn_contour_shade(plot1, 580, 586, res1)

; ========== 588 线加粗 + 橙色填充 ==========
res2 = True
res2@gsnDraw       = False
res2@gsnFrame      = False
res2@cnLinesOn     = True
res2@cnFillOn      = True
res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels             = (/588/)
res2@cnLineColor          = "red3"
res2@cnLineThicknessF     = 3.0
res2@cnLineLabelsOn       = False
res2@cnLabelDrawOrder     = "PostDraw"
res2@cnLineLabelFontHeightF      = 0.010
res2@cnLineLabelBackgroundColor  = "white"
res2@cnLineLabelDensityF = 1
res2@cnLineLabelInterval = 1.5
res2@cnInfoLabelOn       = False
res2@lbLabelBarOn        = False
res2@cnFillDrawOrder     = "PreDraw"
plot2 = gsn_csm_contour(wks, hgt1, res2)
res2@gsnShadeHigh = "orange"
plot2 = gsn_contour_shade(plot2, 580, 588, res2)

; ========== 500hPa 风羽 ==========
resUV = True
resUV@gsnLeftString  = ""
resUV@gsnRightString = ""
resUV@gsnDraw        = False
resUV@gsnFrame       = False

resUV@vcMinDistanceF  = 0.022
resUV@vcMinMagnitudeF = 1.0
resUV@vcPositionMode  = "ArrowTail"
resUV@vcLevelSpacingF = 0.8

resUV@vcRefAnnoOn              = False
resUV@vcRefAnnoSide            = "Top"
resUV@vcRefAnnoBackgroundColor = -1
resUV@vcRefAnnoPerimOn         = False
resUV@vcRefMagnitudeF          = 4

resUV@vcGlyphStyle              = "WindBarb"
resUV@vcWindBarbScaleFactorF    = 2.5
resUV@vcWindBarbColor           = "deepskyblue3"
resUV@vcWindBarbLineThicknessF  = 1.5
resUV@vcRefLengthF              = 0.020

resUV@gsnMaximize       = True
resUV@vcVectorDrawOrder = "PreDraw"

wrf_smooth_2d(uv_speed, 10)
plotUV = gsn_csm_vector(wks, wind_u, wind_v, resUV)

; 叠加
overlay(plot, plot1)
overlay(plot, plot2)
overlay(plot, plotUV)

; ========== 592 线（仅在最大值>=592时绘制）==========
if (max(hgt1) .ge. 592) then
    res3 = True
    res3@gsnDraw       = False
    res3@gsnFrame      = False
    res3@cnLinesOn     = True
    res3@cnFillOn      = False
    res3@cnLevelSelectionMode = "ExplicitLevels"
    res3@cnLevels             = (/592/)
    res3@cnLineColor          = "black"
    res3@cnLineThicknessF     = 3.0
    res3@cnLineLabelsOn       = False
    res3@cnInfoLabelOn        = False
    res3@lbLabelBarOn         = False
    plot3 = gsn_csm_contour(wks, hgt1, res3)
    overlay(plot, plot3)
end if

resP                                  = True
resP@gsnFrame                         = False
resP@gsnPanelLabelBar                 = True
resP@gsnPanelFigureStringsFontHeightF = 0.02
resP@gsnPanelFigureStringsJust        = "TopLeft"
resP@gsnPanelFigureStrings            = (/"(b)"/)
resP@gsnPanelFigureStringsPerimOn     = False
resP@gsnPanelLabelBar                 = False
gsn_panel(wks, plot, (/1,1/), resP)

frame(wks)

delete(wks)
system("convert -trim " + png_name + ".eps " + png_name + ".jpg")

end
