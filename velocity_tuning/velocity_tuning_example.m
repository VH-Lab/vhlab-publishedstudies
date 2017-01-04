function velocity_tuning_example
% VELOCITY_TUNING_EXAMPLE - Several example velocity tuning curves at different speeds

W00 = zeros(13,5);
W00(7,3) = 10;


W22 = [ 0     0     0     0     0
     0     0     0     0     0
     0     0     0     0     0
     0     0     0     0     0
    10     0     0     0     0
     0    10     0     0     0
     0     0    10     0     0
     0     0     0    10     0
     0     0     0     0    10
     0     0     0     0     0
     0     0     0     0     0
     0     0     0     0     0
     0     0     0     0     0 ];

W33 = [ 0     0     0     0     0
     5     0     0     0     0
     0     5     0     0     0
     0    10     0     0     0
     0     5     0     0     0
     0     0     5     0     0
     0     0    10     0     0
     0     0     5     0     0
     0     0     0     0     0
     0     0     0    10     0
     0     0     0     5     0
     0     0     0     0     0
     0     0     0     0     5 ];

W44 = [ 0     0     0     0     0
     0     0     0     0     0
    10     0     0     0     0
     0     0     0     0     0
     0    10     0     0     0
     0     0     0     0     0
     0     0    10     0     0
     0     0     0     0     0
     0     0     0    10     0
     0     0     0     0     0
     0     0     0     0    10
     0     0     0     0     0
     0     0     0     0     0 ];



disp(['Running initial state: ' ]);
W00

out_initial=lgnNRctx_velocitycurve_example('use_lgn_velocity_curve',1,'N',13,'W',W00/10,'dlatency',0.08,...
	'repeats',1,'durr',0.04,'THRESH',1);
title(['Initial']);

disp(['Running fast state: ' ]);
W22

out_fast=lgnNRctx_velocitycurve_example('use_lgn_velocity_curve',1,'N',13,'W',W22/10,'dlatency',0.08,...
	'repeats',1,'durr',0.04,'THRESH',3);
title(['Fast specific']);

disp(['Running slow state: ' ]);
W33

out_slow=lgnNRctx_velocitycurve_example('use_lgn_velocity_curve',1,'N',13,'W',W33/10,'dlatency',0.08,...
	'repeats',1,'durr',0.04,'THRESH',3)
title(['Slow specific']);

disp(['Running predestined state']);
W44

out_predestined=lgnNRctx_velocitycurve_example('use_lgn_velocity_curve',1,'N',13,'W',W44/10,'dlatency',0.08,...
	'repeats',1,'durr',0.04,'THRESH',3)
title(['Predestined hypothesis']);


