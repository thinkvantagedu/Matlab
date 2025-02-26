clear variables; clc;
format long;
%%
addpath('C:\Temp\MATLAB');
addpath('C:\Temp\MATLAB\ABAQUS_MOR');
filename.new='C:\Temp\trimed_textfile_gre.py';
filename.trim='C:\Temp\abaqusMacros_L7H2_dynamics.py';
delete(filename.new);
TrimString(filename.trim, filename.new);
filename=filename.new;
textfile_py=char(importdata(filename, 's'));
str_rmv='def';
textfile_origin=textfile_py;
[textfile]=RemoveOneStringRowinText(textfile_origin, str_rmv);
ConnectionFile='C:\Temp\connection_gre.py';
WrittenFile=textfile;
delete(ConnectionFile);
[WrittenFile]=WriteTextIntoDisk(WrittenFile, ConnectionFile);
INPfilename='C:\Temp\L7H2_dynamics.inp';
FiletoBeInserted='C:\Temp\L7H2_dynamics.inp';
loc_string='nset=Set-lc';
[Inserted_INP]=ABAQUSInsertIntoINP(INPfilename, FiletoBeInserted);
[cons]=ABAQUSReadINPCons(INPfilename, loc_string);
[node, elem]=ABAQUSReadINPGeo(INPfilename);
node_no=node(size(node, 1), 1);
[strtext]=DisplayText(INPfilename);
pm_dist=4;
Strtofind.I1='*Material, name=Material-I1';
[line_node.I1]=FindTextRowNO(INPfilename, Strtofind.I1);
elastic_pm.I1=str2num(strtext(line_node.I1(1)+pm_dist, :));
YoungsM.I1=elastic_pm.I1(:, 1);
Strtofind.I2='*Material, name=Material-I2';
[line_node.I2]=FindTextRowNO(INPfilename, Strtofind.I2);
elastic_pm.I2=str2num(strtext(line_node.I2(1)+pm_dist, :));
YoungsM.I2=elastic_pm.I2(:, 1);
Strtofind.S='*Material, name=Material-S';
[line_node.S]=FindTextRowNO(INPfilename, Strtofind.S);
elastic_pm.S=str2num(strtext(line_node.S(1)+pm_dist, :));
YoungsM.S=elastic_pm.S(:, 1);
domainLength.I1=50;
domainLength.I2=50;
domainLength.S=50;
domainBondL.I1=-1;
domainBondR.I1=1;
domainBondL.I2=-1;
domainBondR.I2=1;
pm.I1=logspace(domainBondL.I1, domainBondR.I1, domainLength.I1);
pm.I2=logspace(domainBondL.I2, domainBondR.I2, domainLength.I2);
pm.S=repmat(domainLength.S, 1, domainLength.I1*domainLength.I2);
pm.comb=zeros(3, domainLength.I1*domainLength.I2);
pm.comb(1:2, :)=combvec(pm.I1, pm.I2);
pm.comb(3, :)=pm.S;
pm.comb=pm.comb';
%%
time_step='0.2';
MaxT=20;
switch time_step
    case '0.4'
        deltaT=0.4;
    case '0.2'
        deltaT=0.2;
    case '0.1'
        deltaT=0.1;
    case '0.05'
        deltaT=0.05;
    case '0.02'
        deltaT=0.02;
    case '0.01'
        deltaT=0.01;
end
iteratives=MaxT/deltaT;
f_node=2;
f_dof=3*f_node-1;
force_t=4;
trial_NO=[1, 1];
if trial_NO(1, 1)>domainLength.I1||trial_NO(1, 2)>domainLength.I2
    error('trial point exceeds pm domain.')
end
pm_trial.I1=pm.I1(trial_NO(1, 1));
pm_trial.I2=pm.I2(trial_NO(1, 2));
pm_trial.S=pm.S(1);
Insert_E.I1=[YoungsM.I1; pm_trial.I1];
Insert_E.I2=[YoungsM.I2; pm_trial.I2];
Insert_E.S=[YoungsM.S; pm_trial.S];
str_E0.I1=num2str(Insert_E.I1, 10);
str_E0.I2=num2str(Insert_E.I2, 10);
str_E0.S=num2str(Insert_E.S, 10);
i_applied_E=1;
[strtext]=ModifyParameter(str_E0.I1, strtext, line_node.I1, pm_dist);
[strtext]=ModifyParameter(str_E0.I2, strtext, line_node.I2, pm_dist);
[strtext]=ModifyParameter(str_E0.S, strtext, line_node.S, pm_dist);
ExistingFilename=strtext;
delete('C:\Temp\abaqus.rpt');
[ExistingFilename]=WriteTextIntoDisk(ExistingFilename, FiletoBeInserted);
system('abaqus cae noGUI=C:\Temp\connection_gre.py'); 
[Cleared_INP]=ABAQUSClearFromINP(INPfilename, INPfilename);
[result_data]=char(importdata('C:\Temp\abaqus.rpt', 's'));
selected_rows_str=result_data(size(result_data, 1)-iteratives+1:size(result_data, 1), :);
[selected_rows_num]=strrows2numrows(selected_rows_str, node_no);
[re_se_rows_num]=DisplacementRows2Cols(selected_rows_num, node_no);
[snap_store]=StoreResultCols(re_se_rows_num, i_applied_E, iteratives);
[U_exact_ini]=ABAQUSDeleteBCRowsinMTX(snap_store, cons, node);

MTX_M_file.ini_iter='C:\Temp\L7H2_dynamics_MASS1.mtx';
MTX_K_file.ini_iter='C:\Temp\L7H2_dynamics_STIF1.mtx';
[MTX_M.ini_iter]=ABAQUSReadMTX(MTX_M_file.ini_iter);
[MTX_K.ini_iter]=ABAQUSReadMTX(MTX_K_file.ini_iter);
MTX_M.ini_iter_free=ABAQUSDeleteBCinMTX(MTX_M.ini_iter, cons, node);
MTX_K.ini_iter_free=ABAQUSDeleteBCinMTX(MTX_K.ini_iter, cons, node);
MTX_C.ini_iter_free=zeros(length(MTX_K.ini_iter_free));
f_amp=zeros(3*length(node), MaxT/deltaT);
f_amp_t=(deltaT:deltaT:force_t);
f_amp_value=-sin(pi/4*f_amp_t);
f_amp(f_dof, 1:length(f_amp_t))=f_amp(f_dof, 1:length(f_amp_t))+f_amp_value;
f_amp_free=ABAQUSDeleteBCRowsinMTX(f_amp, cons, node);
acce='average';
ERR=1;
NPhi=1;
ERR_store=zeros(1, 6);
id_phi=eye(size(MTX_M.ini_iter_free, 1));
U0.phi=zeros(size(MTX_M.ini_iter_free, 1), 1);
V0.phi=zeros(size(MTX_M.ini_iter_free, 1), 1);
A0.phi=zeros(size(MTX_M.ini_iter_free, 1), 1);
%%
[U_ini_R, V_ini_R, A_ini_R, U_ini, V_ini, A_ini, t_ini, time_step_NO_ini]=...
    NewmarkBetaReducedMethod...
    (id_phi, MTX_M.ini_iter_free, MTX_C.ini_iter_free, MTX_K.ini_iter_free, ...
    f_amp_free, acce, deltaT, MaxT, U0.phi, V0.phi, A0.phi);
ERR=abs((norm(U_exact_ini-U_ini, 'fro'))/norm(U_exact_ini, 'fro'));
disp(ERR)
t=[0.4 0.2 0.1 0.05 0.02];
plot(t, ERR)
set ( gca, 'xdir', 'reverse' )
%{
while ERR>1e-8
    
    [X1, Phi.iter, Sigma1]=SVD(snap_store, NPhi);
    Phi.iter_free=ABAQUSDeleteBCRowsinMTX(Phi.iter, cons, node);
    MTX_svd.M=Phi.iter_free'*MTX_M.svd_iter_free*Phi.iter_free;
    MTX_svd.K=Phi.iter_free'*MTX_K.svd_iter_free*Phi.iter_free;
    MTX_svd.C=zeros(length(MTX_svd.K));
    f_amp_free_R=Phi.iter_free'*f_amp_free;
    U0.svd=zeros(NPhi, 1);
    V0.svd=zeros(NPhi, 1);
    A0.svd=zeros(NPhi, 1);
    [U_svd_R, V_svd_R, A_svd_R, U_svd, V_svd, A_svd, t_svd, time_step_NO_svd]=...
        NewmarkBetaReducedMethod...
        (Phi.iter_free, MTX_svd.M, MTX_svd.C, MTX_svd.K, ...
        f_amp_free_R, acce, deltaT, MaxT, U0.svd, V0.svd, A0.svd);
    ERR=abs((norm(U_exact_ini-U_svd, 'fro'))/norm(U_exact_ini, 'fro'));
    ERR_log=log10(ERR);
    ERR_store(NPhi)=ERR_store(NPhi)+ERR;
    ERR_log_store(NPhi)=ERR_log_store(NPhi)+ERR_log;
    disp(ERR)
    disp(NPhi)
    if NPhi>=length(MTX_M.svd_iter_free)
        break
    end
    NPhi=NPhi+1;
end
%}
%%
%{
x=(1:length(MTX_M.svd_iter_free));
[ERR_max, ERR_max_loc]=max(ERR_store(:));
[ERR_min, ERR_min_loc]=max(ERR_store(:));
subplot(1, 2, 1)
plot(x, ERR_store);
legendInfo{1}=['max error = ' num2str(ERR_max) ' Max error location = ' ...
    num2str(ERR_max_loc)];
legend(legendInfo)
set(legend,'FontSize',10);
subplot(1, 2, 2)
plot(x, ERR_log_store);
legendInfo{1}=['log error'];
legend(legendInfo)
set(legend,'FontSize',10);
%%
%{
a=(1:1000);
p1=plot(a, U_exact_ini(7, :));
hold on
p2=plot(a, U_svd(7, :));
hold off
title('Time step = 0.02, x displacement at node 3')
legend([p1, p2], 'exact from ABAQUS', 'svd')
%}
%{
MTX_file_M.I10_I21='C:\Temp\L7H2_dynamics_matrices_I10_I21_MASS1.mtx';
MTX_file_K.I10_I21='C:\Temp\L7H2_dynamics_matrices_I10_I21_STIF1.mtx';
MTX_file_M.I11_I20='C:\Temp\L7H2_dynamics_matrices_I11_I20_MASS1.mtx';
MTX_file_K.I11_I20='C:\Temp\L7H2_dynamics_matrices_I11_I20_STIF1.mtx';
[MTX_M.I10_I21]=ABAQUSReadMTX(MTX_file_M.I10_I21);
[MTX_K.I10_I21]=ABAQUSReadMTX(MTX_file_K.I10_I21);
[MTX_M.I11_I20]=ABAQUSReadMTX(MTX_file_M.I11_I20);
[MTX_K.I11_I20]=ABAQUSReadMTX(MTX_file_K.I11_I20);
MTX_M_free.I10_I21=ABAQUSDeleteBCinMTX(MTX_M.I10_I21, cons, node);
MTX_K_free.I10_I21=ABAQUSDeleteBCinMTX(MTX_K.I10_I21, cons, node);
MTX_M_free.I11_I20=ABAQUSDeleteBCinMTX(MTX_M.I11_I20, cons, node);
MTX_K_free.I11_I20=ABAQUSDeleteBCinMTX(MTX_K.I11_I20, cons, node);
MTX_M_free_R.I10_I21=Phi.iter_free'*MTX_M_free.I10_I21*Phi.iter_free;
MTX_K_free_R.I10_I21=Phi.iter_free'*MTX_K_free.I10_I21*Phi.iter_free;
MTX_M_free_R.I11_I20=Phi.iter_free'*MTX_M_free.I11_I20*Phi.iter_free;
MTX_K_free_R.I11_I20=Phi.iter_free'*MTX_K_free.I11_I20*Phi.iter_free;
id_phi=eye(length(MTX_M_free.I10_I21));
acce='average';
err_store=zeros(length(pm.I1), length(pm.I2));
err_store_log=zeros(length(pm.I1), length(pm.I2));
res_store=zeros(length(pm.I1), length(pm.I2));
resfr_store=zeros(length(pm.I1), length(pm.I2));
MTX_file_iter.M='C:\Temp\L7H2_dynamics_MASS1.mtx';
MTX_file_iter.K='C:\Temp\L7H2_dynamics_STIF1.mtx';
[MTX_iter.M]=ABAQUSReadMTX(MTX_file_iter.M);
[MTX_iter.K]=ABAQUSReadMTX(MTX_file_iter.K);
MTX_iter_free.M=ABAQUSDeleteBCinMTX(MTX_iter.M, cons, node);
MTX_iter_free.K=ABAQUSDeleteBCinMTX(MTX_iter.K, cons, node);
MTX_iter_free.C=zeros(length(MTX_iter_free.M));
U0_iter=zeros(size(MTX_iter_free.M, 1), 1);
V0_iter=zeros(size(MTX_iter_free.M, 1), 1);
A0_iter=zeros(size(MTX_iter_free.M, 1), 1);
i_cnt_iter=1;
for i_ini=1:size(pm.comb, 1)
    M_ini_R=MTX_M_free_R.I11_I20*0.01+MTX_M_free_R.I10_I21*0.001;
    K_ini_R=MTX_K_free_R.I11_I20*pm.comb(i_ini, 1)+MTX_K_free_R.I10_I21*pm.comb(i_ini, 2);
    C_ini_R=zeros(length(M_ini_R));
    M_ini=MTX_M_free.I11_I20*0.01+MTX_M_free.I10_I21*0.001;
    K_ini=MTX_K_free.I11_I20*pm.comb(i_ini, 1)+MTX_K_free.I10_I21*pm.comb(i_ini, 2);
    C_ini=zeros(length(M_ini));
    U0_ini_R=zeros(size(M_ini_R, 1), 1);
    V0_ini_R=zeros(size(M_ini_R, 1), 1);
    A0_ini_R=zeros(size(M_ini_R, 1), 1);
    U0_ini=zeros(size(M_ini, 1), 1);
    V0_ini=zeros(size(M_ini, 1), 1);
    A0_ini=zeros(size(M_ini, 1), 1);
    [U_ini_R, V_ini_R, A_ini_R, U_ini, V_ini, A_ini, t_ini, time_step_NO_ini]=...
        NewmarkBetaReducedMethod...
        (Phi.iter_free, M_ini_R, C_ini_R, K_ini_R, ...
        f_amp_free_R, acce, deltaT, MaxT, U0_ini_R, V0_ini_R, A0_ini_R);
    Res_FR=M_ini*Phi.iter_free*A_ini_R+K_ini*Phi.iter_free*U_ini_R;
    Res=f_amp_free(:, 1:size(Res_FR, 2))-Res_FR;
    [U_err_R, V_err_R, A_err_R, U_err, V_err, A_err, t_err, time_step_NO_err]=...
        NewmarkBetaReducedMethod...
        (id_phi, M_ini, C_ini, K_ini, Res, ...
        acce, deltaT, MaxT, U0_iter, V0_iter, A0_iter);
    err=norm(U_err, 'fro')/norm(U_exact_ini, 'fro');                     
    err_log=log10(err);                                                 
    err_store(i_ini)=err_store(i_ini)+err;                              
    err_store_log(i_ini)=err_store_log(i_ini)+err_log;                  
    res_store(i_ini)=res_store(i_ini)+norm(Res, 'fro');
    resfr_store(i_ini)=resfr_store(i_ini)+norm(Res_FR, 'fro');
end
subplot(1, 1, i_cnt_iter)
surf(linspace(domainBondL.I1, domainBondR.I1, domainLength.I1), ...
    linspace(domainBondL.I2, domainBondR.I2, domainLength.I2), err_store_log);
axis([-1 1 -1 1])
view(3)
disp('iteration')
disp(i_cnt_iter);
[err_max_log, err_max_log_loc]=max(err_store_log(:));                   
[err_max, err_max_loc]=max(err_store(:));                               
legendInfo{i_cnt_iter}=['Iteration = ' num2str(i_cnt_iter) ' Max error = ' num2str(err_max_loc)];
legend(legendInfo)
set(legend,'FontSize',8);
disp('max err=')                                                        
disp(err_max)                                                           
disp('max err loc=')
disp(err_max_loc)     
%}
%%

snap_store_comb=[];
err_store=zeros(length(pm.I1), length(pm.I2));
err_store_log=zeros(length(pm.I1), length(pm.I2));
res_store=zeros(length(pm.I1), length(pm.I2));
resfr_store=zeros(length(pm.I1), length(pm.I2));
elastic_pm.I1=str2num(strtext(line_node.I1(1)+pm_dist, :));
elastic_pm.I2=str2num(strtext(line_node.I2(1)+pm_dist, :));
elastic_pm.S=str2num(strtext(line_node.S(1)+pm_dist, :));
num_iterE.I1(1, :)=elastic_pm.I1(:, 1);
num_iterE.I2(1, :)=elastic_pm.I2(:, 1);
num_iterE.S(1, :)=elastic_pm.S(:, 1);
num_iterE.I1(2, :)=pm.comb(err_max_loc, 1);
num_iterE.I2(2, :)=pm.comb(err_max_loc, 2);
num_iterE.S(2, :)=pm.comb(err_max_loc, 3);
str_iterE.I1=num2str(num_iterE.I1, 6);
str_iterE.I2=num2str(num_iterE.I2, 6);
str_iterE.S=num2str(num_iterE.S, 6);
[strtext]=ModifyParameter(str_iterE.I1, strtext, line_node.I1, pm_dist);
[strtext]=ModifyParameter(str_iterE.I2, strtext, line_node.I2, pm_dist);
[strtext]=ModifyParameter(str_iterE.S, strtext, line_node.S, pm_dist);

%}












