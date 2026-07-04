; =====================================================================
; mkfig5d.ncl - 海平面气压（SLP）等值线
; 绘制2026年5月18日21时（UTC）
; =============================================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-------------------- 固定时次 --------------------
year  = "2026"
mon   = "05"
day   = "18"
hour  = 21
;-------------------------------------------------

; 读ERA5数据
f  = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/mean_sea_level_pressure/" + "era5.mean_sea_level_pressure." + year + mon + day + ".nc", "r")

SLP_1 = f->msl(hour,:,:)
slp   = SLP_1 / 100
lat   = f->latitude
lon   = f->longitude
copy_VarCoords(SLP_1, slp)

;----------------------------------------------------------------------
png_name = "./figures/Figure6d"
wks = gsn_open_wks("eps", png_name)

;-- 地图参数 ----------------------------------------------------------------
res = True
res@gsnDraw  = False
res@gsnFrame = False

res@mpMinLatF = 10.0
res@mpMaxLatF = 30.0
res@mpMinLonF = 95.0
res@mpMaxLonF = 125.0

res@mpProjection = "LambertEqualArea"
res@mpLimitMode  = "LatLon"
res@mpCenterLatF = (res@mpMinLatF + res@mpMaxLatF) / 2.
res@mpCenterLonF = (res@mpMinLonF + res@mpMaxLonF) / 2.

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
res@mpDataSetName         = "./database/Earth..4"
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

; SLP等值线
res@cnLinesOn            = True
res@cnFillOn             = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF       = 970
res@cnMaxLevelValF       = 1100
res@cnLevelSpacingF      = 2.5

res@cnLineDashPattern    = 0
res@cnMonoLineColor      = False
res@cnLineColors         = span_color_rgba("MPL_gist_rainbow", 33)
res@cnLineThicknessF     = 2

res@cnLineLabelsOn       = True
res@cnLabelDrawOrder     = "PostDraw"
res@cnLineLabelFontHeightF      = 0.010
res@cnLineLabelFontThicknessF   = 1.87
res@cnMonoLineLabelFontColor    = False
res@cnLineLabelFontColors       = span_color_rgba("MPL_gist_rainbow", 33)
res@cnLineLabelBackgroundColor  = "white"
res@cnLineLabelDensityF  = 0.7
res@cnLineLabelInterval  = 1.8
res@cnLineLabelFormat    = "f"

res@cnLineDrawOrder      = "Postdraw"
res@cnInfoLabelOn        = False

; 高低中心标签
res@cnHighLabelsOn              = False
res@cnHighLabelBackgroundColor  = -1
res@cnHighLabelFontHeightF      = 0.011
res@cnHighLabelConstantSpacingF = 1
res@cnHighLabelFontColor        = "blue3"
res@cnLowLabelsOn               = False

; 色标（不需要）
res@lbLabelBarOn  = False
res@cnFillOpacityF = 1

; 空间平滑
slp1 = slp
wrf_smooth_2d(slp1, 12)

plot = gsn_csm_contour_map(wks, slp1, res)

; Shapefile 叠加（省界 + 港澳界）
ShpDir = "./cnmap/"

provres                  = True
provres@gsLineThicknessF = 1.5
provres@gsLineColor      = "gray"
provres@minlon           = 109
provres@maxlon           = 118
provres@minlat           = 20
provres@maxlat           = 26

hkres                    = True
hkres@gsLineThicknessF   = 1.5
hkres@gsLineColor        = "gray"
hkres@gsLineDashPattern  = 2
hkres@minlon             = 109
hkres@maxlon             = 118
hkres@minlat             = 20
hkres@maxlat             = 26

plotprovince = gsn_add_shapefile_polylines(wks, plot, ShpDir + "province_10south.shp", provres)
plotdiqu     = gsn_add_shapefile_polylines(wks, plot, ShpDir + "china_polyline.shp", hkres)

; Panel 标注 (d)
resP                                  = True
resP@gsnFrame                         = False
resP@gsnPanelFigureStringsFontHeightF = 0.02
resP@gsnPanelFigureStringsJust        = "TopLeft"
resP@gsnPanelFigureStrings            = (/"(d)"/)
resP@gsnPanelFigureStringsPerimOn     = False
resP@gsnPanelLabelBar                 = False
gsn_panel(wks, plot, (/1, 1/), resP)

frame(wks)

delete(wks)
system("convert -trim -density 600x600 " + png_name + ".eps " + png_name + ".jpg")

end
