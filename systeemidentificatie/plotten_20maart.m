subplot(3,2,1)
plot(localtime(range),gemiddelde_zon,'b',localtime(range),warmtepomp,'r',localtime(range),inp.Q_gas,'g')
subplot(3,2,2)
plot(localtime(range),buitentemp)
subplot(3,2,3)
plot(localtime(range),T_berekend,'b',localtime(range),gemiddelde_temp,'r')
subplot(3,2,4)
plot(localtime(range),T_opp,'b',localtime(range),T_kern,'r')
subplot(3,2,5)
plot(localtime(range),((35./(35-buitentemp)).*cf_COP))

figure

subplot(3,2,1)
plot(localtime(range_crossval),gemiddelde_zon_crossval,'b',localtime(range_crossval),warmtepomp_crossval,'r',localtime(range_crossval),verw_gas_crossval,'g')
subplot(3,2,2)
plot(localtime(range_crossval),buitentemp_crossval)
subplot(3,2,3)
plot(localtime(range_crossval),T_berekend_crossval,'b',localtime(range_crossval),gemiddelde_temp_crossval,'r')
subplot(3,2,4)
plot(localtime(range_crossval),T_opp_crossval,'b',localtime(range_crossval),T_kern_crossval,'r')
subplot(3,2,5)

plot(localtime(range_crossval),((35./(35-buitentemp_crossval)).*cf_COP))