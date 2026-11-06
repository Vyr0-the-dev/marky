import React from 'react';
import {
  AbsoluteFill,
  Composition,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

const FPS = 30;
const DURATION = 360;
const WIDTH = 1080;
const HEIGHT = 1920;

export const Root: React.FC = () => {
  return (
    <Composition
      id="MarkyLaunch"
      component={MarkyLaunch}
      durationInFrames={DURATION}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
      defaultProps={{}}
    />
  );
};

const fade = (frame: number, start: number, end: number): number =>
  interpolate(frame, [start, end], [0, 1], {
    easing: Easing.inOut(Easing.cubic),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

const windowed = (frame: number, start: number, end: number, pad = 14): number =>
  interpolate(frame, [start - pad, start, end, end + pad], [0, 1, 1, 0], {
    easing: Easing.inOut(Easing.cubic),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

const MarkyLaunch: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const intro = spring({
    frame,
    fps,
    config: {damping: 18, mass: 0.78, stiffness: 130},
  });
  const final = fade(frame, 288, 340);

  return (
    <AbsoluteFill className="scene">
      <Background frame={frame} />
      <KineticWords frame={frame} />
      <FlyingLinks frame={frame} />
      <Phone frame={frame} intro={intro} />
      <CapturePills frame={frame} />
      <AbsoluteFill className="blackout" style={{opacity: final}} />
      <FinalMark frame={frame} opacity={final} />
    </AbsoluteFill>
  );
};

const Background: React.FC<{frame: number}> = ({frame}) => {
  return (
    <AbsoluteFill>
      <div
        className="halo halo-a"
        style={{transform: `translate3d(${Math.sin(frame / 24) * 38}px, ${Math.cos(frame / 31) * 22}px, 0)`}}
      />
      <div
        className="halo halo-b"
        style={{transform: `translate3d(${Math.cos(frame / 27) * -32}px, ${Math.sin(frame / 29) * 28}px, 0)`}}
      />
      <div className="paper-grid" />
    </AbsoluteFill>
  );
};

const KineticWords: React.FC<{frame: number}> = ({frame}) => {
  const beats = [
    {start: 6, end: 92, kicker: 'The web moves fast.', title: 'Keep the good links.'},
    {start: 104, end: 194, kicker: 'Share. QR. Clipboard.', title: 'Capture in one tap.'},
    {start: 206, end: 292, kicker: 'Unread, reminders, search.', title: 'Read when you are ready.'},
  ];

  return (
    <>
      {beats.map((beat) => {
        const o = windowed(frame, beat.start, beat.end, 12);
        return (
          <div
            key={beat.title}
            className="words"
            style={{
              opacity: o,
              transform: `translateY(${interpolate(o, [0, 1], [28, 0])}px)`,
            }}
          >
            <span>{beat.kicker}</span>
            <h1>{beat.title}</h1>
          </div>
        );
      })}
    </>
  );
};

const FlyingLinks: React.FC<{frame: number}> = ({frame}) => {
  const links = [
    ['article', 'uxdesign.cc', -200, 520, 18, 0],
    ['docs', 'flutter.dev', 1040, 710, -13, 18],
    ['repo', 'github.com', -180, 1010, -9, 36],
    ['recipe', 'substack.com', 980, 1180, 12, 54],
  ] as const;

  return (
    <AbsoluteFill>
      {links.map(([title, host, x, y, rotate, delay]) => {
        const t = fade(frame, 22 + delay, 92 + delay);
        const travel = interpolate(t, [0, 1], [0, x < 0 ? 760 : -760]);
        return (
          <div
            key={title}
            className="fly-card"
            style={{
              left: x,
              top: y,
              opacity: interpolate(t, [0, 0.18, 0.82, 1], [0, 0.86, 0.86, 0]),
              transform: `translateX(${travel}px) rotate(${rotate}deg) scale(${0.9 + t * 0.08})`,
            }}
          >
            <b>{title}</b>
            <span>{host}</span>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

const Phone: React.FC<{frame: number; intro: number}> = ({frame, intro}) => {
  const tilt = interpolate(frame, [0, 120, 220, 320], [-4, 1, -1.5, 0], {
    easing: Easing.inOut(Easing.cubic),
    extrapolateRight: 'clamp',
  });
  const y = interpolate(frame, [0, 120, 240, 330], [92, 18, -28, -108], {
    easing: Easing.inOut(Easing.cubic),
    extrapolateRight: 'clamp',
  });

  return (
    <div
      className="phone-wrap"
      style={{
        opacity: intro,
        transform: `translate3d(0, ${y + interpolate(intro, [0, 1], [130, 0])}px, 0) rotate(${tilt}deg) scale(${0.9 + intro * 0.1})`,
      }}
    >
      <div className="phone-shadow" />
      <div className="phone">
        <div className="notch" />
        <div className="screen">
          <Status />
          <ShareScene frame={frame} />
          <SavedScene frame={frame} />
          <LibraryScene frame={frame} />
        </div>
      </div>
    </div>
  );
};

const Status: React.FC = () => (
  <div className="status">
    <span>9:41</span>
    <span>5G 100%</span>
  </div>
);

const ShareScene: React.FC<{frame: number}> = ({frame}) => {
  const opacity = windowed(frame, 0, 132, 18);
  const sheet = fade(frame, 50, 84);
  const toast = windowed(frame, 84, 132, 8);
  return (
    <div className="screen-layer share" style={{opacity}}>
      <div className="browser-card">
        <span>Reading now</span>
        <h2>Better habits for deep work</h2>
        <p>A practical guide worth keeping for later.</p>
      </div>
      <div
        className="share-sheet"
        style={{transform: `translateY(${interpolate(sheet, [0, 1], [240, 0])}px)`}}
      >
        <i />
        <small>Share with</small>
        <div className="target">
          <b>M</b>
          <div>
            <strong>Marky</strong>
            <span>Save quietly</span>
          </div>
        </div>
      </div>
      <div
        className="top-toast"
        style={{
          opacity: toast,
          transform: `translateY(${interpolate(toast, [0, 1], [-20, 0])}px)`,
        }}
      >
        <b>Saved</b>
        <span>Open</span>
      </div>
    </div>
  );
};

const SavedScene: React.FC<{frame: number}> = ({frame}) => {
  const opacity = windowed(frame, 118, 228, 18);
  const check = fade(frame, 134, 162);
  return (
    <div className="screen-layer saved" style={{opacity}}>
      <AppHeader title="Add" chip="Manual" />
      <div className="url-field">https://example.com/deep-work</div>
      <div className="save-result">
        <div
          className="check"
          style={{transform: `scale(${interpolate(check, [0, 1], [0.25, 1])})`}}
        >
          ✓
        </div>
        <h2>Saved!</h2>
        <p>No clutter. No duplicate mess.</p>
      </div>
      <div className="duplicate-note">Already saved? Marky gives you Open.</div>
    </div>
  );
};

const LibraryScene: React.FC<{frame: number}> = ({frame}) => {
  const opacity = fade(frame, 210, 244);
  const unread = Math.round(interpolate(frame, [214, 280], [4, 18], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  }));
  return (
    <div className="screen-layer library" style={{opacity}}>
      <AppHeader title="Home" chip={`${unread} unread`} />
      <div className="filter"><b>Unread</b><span>Favorites</span><span>Archive</span></div>
      <LinkRow title="Better habits for deep work" host="example.com" tag="Unread" />
      <LinkRow title="Flutter release checklist" host="docs.flutter.dev" tag="Code" />
      <LinkRow title="Design systems that last" host="uxdesign.cc" tag="Saved" />
      <div className="reminder-strip">Tonight · return to unread links</div>
      <Nav />
    </div>
  );
};

const AppHeader: React.FC<{title: string; chip: string}> = ({title, chip}) => (
  <div className="app-header">
    <div><small>Marky</small><strong>{title}</strong></div>
    <span>{chip}</span>
  </div>
);

const LinkRow: React.FC<{title: string; host: string; tag: string}> = ({title, host, tag}) => (
  <div className="row">
    <i>{host[0].toUpperCase()}</i>
    <div><b>{title}</b><span>{host}</span></div>
    <em>{tag}</em>
  </div>
);

const Nav: React.FC = () => (
  <div className="nav">
    <span>Home</span><span>Search</span><b>＋</b><span>Library</span><span>Settings</span>
  </div>
);

const CapturePills: React.FC<{frame: number}> = ({frame}) => {
  const opacity = windowed(frame, 102, 214, 18);
  return (
    <div className="pills" style={{opacity}}>
      <span>Share sheet</span>
      <span>QR</span>
      <span>Clipboard</span>
    </div>
  );
};

const FinalMark: React.FC<{frame: number; opacity: number}> = ({frame, opacity}) => {
  const {fps} = useVideoConfig();
  const enter = spring({
    frame: frame - 302,
    fps,
    config: {damping: 17, mass: 0.75, stiffness: 140},
  });
  return (
    <div
      className="final"
      style={{
        opacity,
        transform: `translateY(${interpolate(enter, [0, 1], [34, 0])}px)`,
      }}
    >
      <div className="mark">M</div>
      <h2>Marky</h2>
      <p>Save links. Read later.</p>
    </div>
  );
};
