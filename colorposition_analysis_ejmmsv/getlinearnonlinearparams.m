function [LSlin, LSnonlin, LINparams, NonlinParams] =getlinearnonlinearparams(cell)

NK = findassociate(cell,'TP CEDE Color NK Fit Params','','');
LIN = findassociate(cell,'TP CEDE Color Fit Params','','');

LSlin = LIN.data(1:2);

LSnonlin = [NK.data(1)*naka_rushton_func(1,NK.data(3),NK.data(5)) NK.data(2)*naka_rushton_func(1,NK.data(4),NK.data(6)) ];

LINparams = LIN.data;

NonlinParams = NK.data;

