function initScreen(num_dots_patch, mon_width_cm, view_dist_cm)
% 
% function initScreen(num_dots_patch, mon_horizontal_cm, view_dist_cm)
% initializes the screen 
% 
% Input:
%   screen_struct
% 
% Output
%   screen_struct
% 

% 
% 09/26/07,  Roozbeh Kiani
% 

global screen_struct dots_struct  


% 1. OPEN THE SCREEN.
    % check whether the requested screen is available 
avail_screen = Screen('Screens');
if ~ismember(screen_struct.cur_screen, avail_screen)
    error('The requested screen is not available');
end
    % if cur_window is valid close it before openning a new one 
avail_window = Screen('Windows');
if ismember(screen_struct.cur_window, avail_window)
    Screen('Close', screen_struct.cur_window);
end
[screen_struct.cur_window, screen_struct.screen_rect] = ...
    Screen(screen_struct.cur_screen, 'OpenWindow', screen_struct.screen_bkg);


% 2. COMPUTE PIXELS PER DEGREE for the given screen
% use the horizontal dimension of the screen and the viewing distance
if nargin<3 || isempty(mon_width_cm)
    mon_width_cm = Screen('DisplaySize', screen_struct.cur_screen) / 10;
    if ~isequal(mon_width_cm,0)
        if ~isempty(screen_struct.mon_width_cm) && screen_struct.mon_width_cm~=mon_width_cm
            warning('InitScreen:MonitorSizeMismatch', 'Monitor''s physical size is different from the specified size');
        end
        screen_struct.mon_width_cm = mon_width_cm;
    else
        if isempty(screen_struct.mon_width_cm)
            warning('InitScreen:MonitorSizeUnknown', 'Monitor''s physical size is unknown, set to 38 cm');
            screen_struct.mon_width_cm = 38;
        end
    end
else
    screen_struct.mon_width_cm = mon_width_cm;
end


if nargin<4 || isempty(view_dist_cm)
    if isempty(screen_struct.view_dist_cm)
        warning('InitScreen:MonitorDistanceUnknown', 'Monitor''s physical distance is unknown, set to 60 cm');
        screen_struct.view_dist_cm = 60;
    end
else
    screen_struct.view_dist_cm = view_dist_cm;
end

% (pix/screen) * ... (screen/rad) * ... rad/deg
screen_struct.pix_per_deg = screen_struct.screen_rect(3) * ...
                            (1 ./ (2 * atan2(screen_struct.mon_width_cm / 2, screen_struct.view_dist_cm))) * ...
                            pi/180;


% 3. Get monitor refresh rate
rate = Screen('NominalFrameRate', screen_struct.cur_screen);
if rate<=0
    fprintf('\nCannot check the refresh rate. Relying on the user supplied value (%g Hz).\n', screen_struct.mon_refresh);
else
    if ~isempty(screen_struct.mon_refresh)
        if abs(screen_struct.mon_refresh-rate)>1
            error('InitScreen:FrameRateMismatch', 'Monitor''s refresh rate is different from the specified refresh rate');
        end
    end
    screen_struct.mon_refresh = rate;
end


% 4. Hide the cursor
HideCursor;


if nargin<2 || isempty(num_dots_patch)
    num_dots_patch = 1;
end
dots_struct = repmat(dots_struct(1), num_dots_patch, 1);



