function dotsShow(rseed, duration)

%
% function dotsShow(rseed, duration)
%
%   rseed   random seed. can be a single value or an array. if an
%           the state of the random number generator is set to prod(rseed).
%   duration    is seconds
%

%
% 09/26/07,  Roozbeh
%

global screen_struct dots_struct



%% function parameters

    %reset the random number
if nargin>=1 && ~isempty(rseed)
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',prod(rseed)));

    RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));


    %set maximum dots duration to 10 sec, if not
if nargin<2 || isempty(duration)
    duration = 10;



%% Initialize dots

    %set the variables that will be needed for the calculation of dots
aperture = dots_struct.aperture;
direction = dots_struct.direction;
density = dots_struct.density;
    %calculate the number of dots for a 'rectangular' aperture.
    %will apply an oval mask at each frame later.
ndots = min(MAX_DOTS_PER_FRAME, ...
            round(density .* (aperture(:,3).*aperture(:,4)) / screen_struct.mon_refresh));
loopi = 1;
dot_angle = pi*direction/180;
    %define an elliptic aperture in screen
AP.type = 'ellipse';
AP.spec.center = deg2screen(aperture(1:2), screen_struct, 'v');
AP.spec.radius = aperture(3:4)/2 * screen_struct.pix_per_deg;
    %find the xy displacement of coherent
dxdy = repmat(dots_struct.speed*dots_struct.interval/screen_struct.mon_refresh*...
              [cos(dot_angle) -sin(dot_angle)], ndots, 1) * screen_struct.pix_per_deg;
d_ppd = repmat(AP.spec.radius, ndots, 1);
dot_pos = (rand(ndots,2,dots_struct.interval)-0.5)*2;
for j = 1 : dots_struct.
    dot_pos(:,:,j) = dot_pos(:,:,j) .* d_ppd;

    %make a copy of AP with aperture center set to zero (
    %for the mask)
AP_ = AP;
AP_.spec.center = [0 0];


%% draw dots on the screen


start_t = GetSecs;


while 1     %enless

    cur_t = GetSecs - start_t;

    if cur_t >=
        break;


    % update dots positions and draw them on the
        %find the index of coherently moving dots in this
    L = rand(ndots,1) < dots_struct.coherence;
        %move the coherent
    dot_pos(L,:,loopi) = dot_pos(L,:,loopi) + dxdy(L,:);
        %replace the other
    dot_pos(~L,:,loopi) = (rand(sum(~L),2)-0.5)*2 .* d_ppd(~L,:);
        %wrap
    L = dot_pos(:,1,loopi) > d_ppd(:,1);
    dot_pos(L,1,loopi) = dot_pos(L,1,loopi) - 2*d_ppd(L,1);
    L = dot_pos(:,1,loopi) < -d_ppd(:,1);
    dot_pos(L,1,loopi) = 2*d_ppd(L,1) - dot_pos(L,1,loopi);
    L = dot_pos(:,2,loopi) > d_ppd(:,2);
    dot_pos(L,2,loopi) = dot_pos(L,2,loopi) - 2*d_ppd(L,2);
    L = dot_pos(:,2,loopi) < -d_ppd(:,2);
    dot_pos(L,2,loopi) = 2*d_ppd(L,2) - dot_pos(L,2,loopi);
        %find the dots that will be shown in the aperture. note that
        %is calculated relative to the center of the aperture (not the screen). use
        %AP_ for filtering.
    L = isInsideRegion(dot_pos(:,:,loopi), AP_);
        %round dot_pos and transpose it because Screen wants positions in row
    pos = round(dot_pos(L,:,loopi))';
        %draw on the
    if any(isnan(prod(pos,1))==0)
        Screen('DrawDots', screen_struct.cur_window, pos, dots_struct.dot_size, dots_struct.dot_color', AP.spec.center);

        %update the loop
    loopi = loopi + 1;
    if loopi > dots_struct.
        loopi = 1;


        %flip the screen to make things
    Screen('Flip', screen_struct.cur_window);


    %flip the screen to clean it
Screen('Flip', screen_struct.cur_window);




