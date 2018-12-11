filename = '~/Downloads/ep_test_20170101_000000_000000.bin';

EPSI = mod_read_epsi_raw(filename);

% ramp diff array
ramp_diff = diff(EPSI.epsi.ramp_count);
% identify array index of ramp diff that are greater than 1
ramp_diff_bool = ramp_diff ~= 1;

figure(1); clf;
ax(1) = subplot(4,1,1);
plot(EPSI.epsi.EPSInbsample, EPSI.epsi.ramp_count,'r.');
h= legend('ramp count');
h.FontSize = 18;
grid on;
axis tight;

ax(2) = subplot(4,1,2);
plot(EPSI.epsi.EPSInbsample(1:end-1), ramp_diff,'r.');
ylim([-20 470])
h= legend('ramp diff');
h.FontSize = 18;
grid on;
%axis tight;



ax(3) = subplot(4,1,3);
plot(EPSI.epsi.EPSInbsample(1:end-1), ramp_diff, 'r.');
ylim([-5 5])
h= legend('ramp diff');
h.FontSize = 18;
grid on;

% find diff of the ramp_diff to get spacing (we're looking for small
%   numbers here to show sequential locations)
ramp_diff_diff = int32(ramp_diff_bool) .* ramp_diff;

ax(4) = subplot(4,1,4);
plot(EPSI.epsi.EPSInbsample(1:end-1), ramp_diff_diff, 'r.');
h= legend('ramp diff');
h.FontSize = 18;
grid on;
axis tight;


linkaxes(ax,'x');

