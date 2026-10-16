/// Photos are loaded from the internet (Unsplash). If a photo cannot load,
/// the app shows a plain placeholder instead.
const _base = 'https://images.unsplash.com/';

String _u(String id, int w) => '$_base$id?w=$w&q=80&auto=format&fit=crop';

const _gym = 'photo-1534438327276-14e5300c3a48';
const _barbell = 'photo-1583454110551-21f2fa2afe61';
const _rack = 'photo-1581009146145-b5ef050c2e1e';
const _lift = 'photo-1534258936925-c58bed479fcb';

String photoGym(int w) => _u(_gym, w);
String photoBarbell(int w) => _u(_barbell, w);
String photoRack(int w) => _u(_rack, w);
String photoLift(int w) => _u(_lift, w);
