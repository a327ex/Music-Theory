require 'anchor'

function init()
  an:anchor_start('Chordbank', 940, 940, 1, 1, 'tidal_waver')
  an:input_bind_all()
  an:font('JPN16', 'assets/Mx437_DOS-V_re_JPN16.ttf', 16)

  an:shader('shadow', nil, [[
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
      return vec4(0.15, 0.15, 0.15, Texel(texture, tc).a*0.5);
    }
  ]])

  back = object():layer()
  shadow = object():layer()
  game = object():layer()
  front = object():layer()
  ui = object():layer()

  function an:draw_layers()
    back:layer_draw_commands()
    game:layer_draw_commands()
    front:layer_draw_commands()
    ui:layer_draw_commands()

    shadow:layer_draw_to_canvas('main', function()
      game:layer_draw('main', 0, 0, 0, 1, 1, an.colors.white[0], 'shadow', true)
      front:layer_draw('main', 0, 0, 0, 1, 1, an.colors.white[0], 'shadow', true)
      ui:layer_draw('main', 0, 0, 0, 1, 1, an.colors.white[0], 'shadow', true)
    end)

    self:layer_draw_to_canvas('main', function()
      back:layer_draw()
      shadow.x, shadow.y = 1.5, 1.5
      shadow:layer_draw()
      game:layer_draw()
      front:layer_draw()
      ui:layer_draw()
    end)

    self:layer_draw('main', 0, 0, 0, self.sx, self.sy)
  end

  flash_color = an.colors.white[0]
  key = 'C'
  create_key_buttons()
  create_key_fields()
end

function create_key_buttons()
  local keys = {'C', 'C#', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B', 'Cb'}
  an:add(object('key_buttons'))
  for i = 1, 15 do
    an.key_buttons:add(an:ui_button_lt(20 + (i-1)*32, 20, 24, 24, function(self)
      key = self.key
      set_key_field_key(1, key)
    end):build(function(self)
      self.key = keys[i]
    end):action(function(self, dt)
      game:rectangle(self.x, self.y, self.w, self.h, 0, 0, an.colors.white[0], 1)
      game:draw_text(self.key, 'JPN16', self.x, self.y)
    end))
  end
end

function create_key_fields()
  an:add(object('key_field_1'):build(function(self)
    self.key_grid = self:ui_grid_lt(20, 80, an.w - 40, 10*24, 8, 10)
  end):action(function(self, dt)
    for _, _, c in self.key_grid:grid_pairs() do
      game:rectangle(c.x, c.y, c.w, c.h, 0, 0, an.colors.white[0], 1)
      game:draw_text(c and c.content or '', 'JPN16', c.x, c.y)
    end
  end))

  an:add(object('key_field_2'):build(function(self)
    self.key_grid = self:ui_grid_lt(20, 392, an.w - 40, 10*24, 8, 10)
  end):action(function(self, dt)
    for _, _, c in self.key_grid:grid_pairs() do
      game:rectangle(c.x, c.y, c.w, c.h, 0, 0, an.colors.white[0], 1)
      game:draw_text(c and c.content or '', 'JPN16', c.x, c.y)
    end
  end))
end

function set_key_field_key(key_field, key)
  local index_to_static_content = {
    [{1, 2}] = 'Ionian',
    [{1, 3}] = 'Dorian',
    [{1, 4}] = 'Phrygian',
    [{1, 5}] = 'Lydian',
    [{1, 6}] = 'Mixolydian',
    [{1, 7}] = 'Aeolian',
    [{1, 8}] = 'Locrian',
    [{1, 9}] = 'Harmonic',
    [{1, 10}] = 'Functional',
    [{2, 1}] = '1',
    [{3, 1}] = '2',
    [{4, 1}] = '3',
    [{5, 1}] = '4',
    [{6, 1}] = '5',
    [{7, 1}] = '6',
    [{8, 1}] = '7',
  }
  local index_to_mode = {'', 'Ionian', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Aeolian', 'Locrian', 'Harmonic', 'Functional'}
  local key_to_chords = {
    ['C'] = { -- C, D, E, F, G, A, B
      Ionian_3 =     {'C',     'Dm',    'Em',     'F',      'G',     'Am',    'Bdim'},
      Ionian_4 =     {'CM7',   'Dm7',   'Em7',    'FM7',    'G7',    'Am7',   'Bm7b5'},
      Dorian_3 =     {'Cm',    'Dm',    'Eb',     'F',      'Gm',    'Adim',  'Bb'},
      Dorian_4 =     {'Cm7',   'Dm7',   'EbM7',   'F7',     'Gm7',   'Am7b5', 'BbM7'},
      Phrygian_3 =   {'Cm',    'Db',    'Eb',     'Fm',     'Gdim',  'Ab',    'Bbm'},
      Phrygian_4 =   {'Cm7',   'DbM7',  'Eb7',    'Fm7',    'Gm7b5', 'AbM7',  'Bbm7'},
      Lydian_3 =     {'C',     'D',     'Em',     'F#dim',  'G',     'Am',    'Bm'},
      Lydian_4 =     {'CM7',   'D7',    'Em7',    'F#m7b5', 'GM7',   'Am7',   'Bm7'},
      Mixolydian_3 = {'C',     'Dm',    'Edim',   'F',      'Gm',    'Am',    'Bb'},
      Mixolydian_4 = {'C7',    'Dm7',   'Em7b5',  'FM7',    'Gm7',   'Am7',   'BbM7'},
      Aeolian_3 =    {'Cm',    'Ddim',  'Eb',     'Fm',     'Gm',    'Ab',    'Bb'},
      Aeolian_4 =    {'Cm7',   'Dm7b5', 'EbM7',   'Fm7',    'Gm7',   'AbM7',  'Bb7'},
      Locrian_3 =    {'Cdim',  'Db',    'Ebm',    'Fm',     'Gb',    'Ab',    'Bbm'},
      Locrian_4 =    {'Cm7b5', 'DbM7',  'Ebm7',   'Fm7',    'GbM7',  'Ab7',   'Bbm7'},
      Harmonic_3 =   {'Cm',    'Ddim',  'Eb+',    'Fm',     'G',     'Ab',    'Bdim'},
      Harmonic_4 =   {'CmM7',  'Dm7b5', 'EbM7+5', 'Fm7',    'G7',    'AbM7',  'Bdim'},
      Functional_3 = {'Cm',    'Ddim',  'Eb',     'Fm',     'G',     'Ab',    'Bdim'},
      Functional_4 = {'Cm7',   'Dm7b5', 'EbM7',   'Fm7',    'G7',    'AbM7',  'Bdim'},
    },
    ['C#'] = { -- C#, D#, E#, F#, G#, A#, B#
      Ionian_3 =     {'C#',     'D#m',    'E#m',    'F#',     'G#',     'A#m',    'B#dim'},
      Ionian_4 =     {'C#M7',   'D#m7',   'E#m7',   'F#M7',   'G#7',    'A#m7',   'B#m7b5'},
      Dorian_3 =     {'C#m',    'D#m',    'E',      'F#',     'G#m',    'A#dim',  'B'},
      Dorian_4 =     {'C#m7',   'D#m7',   'EM7',    'F#7',    'G#m7',   'A#m7b5', 'BM7'},
      Phrygian_3 =   {'C#m',    'D',      'E',      'F#m',    'G#dim',  'A',      'Bm'},
      Phrygian_4 =   {'C#m7',   'DM7',    'E7',     'F#m7',   'G#m7b5', 'AM7' ,   'Bm7'},
      Lydian_3 =     {'C#',     'D#',     'E#m',    'Fxdim',  'G#',     'A#m',    'B#m'},
      Lydian_4 =     {'C#M7',   'D#7',    'E#m7',   'Fxm7b5', 'G#M7',   'A#m7',   'B#m7'},
      Mixolydian_3 = {'C#',     'D#m',    'E#dim',  'F#',     'G#m',    'A#m',    'B'},
      Mixolydian_4 = {'C#7',    'D#m7',   'E#m7b5', 'F#M7',   'G#m7',   'A#m7',   'BM7'},
      Aeolian_3 =    {'C#m',    'D#dim',  'E',      'F#m',    'G#m',    'A',      'B'},
      Aeolian_4 =    {'C#m7',   'D#m7b5', 'EM7',    'F#m7',   'G#m7',   'AM7',    'B7'},
      Locrian_3 =    {'C#dim',  'D',      'Em',     'F#m',    'G',      'A',      'Bm'},
      Locrian_4 =    {'C#m7b5', 'DM7',    'Em7',    'F#m7',   'GM7',    'A7',     'Bm7'},
      Harmonic_3 =   {'C#m',    'D#dim',  'E+',     'F#m',    'G#',     'A',      'B#dim'},
      Harmonic_4 =   {'C#mM7',  'D#m7b5', 'EM7+5',  'F#m7',   'G#7',    'AM7',    'B#dim'},
      Functional_3 = {'C#m',    'D#dim',  'E',      'F#m',    'G#',     'A',      'B#dim'},
      Functional_4 = {'C#m7',   'D#m7b5', 'EM7',    'F#m7',   'G#7',    'AM7',    'B#dim'},
    },
    ['Db'] = { -- Db, Eb, F, Gb, Ab, Bb, C
      Ionian_3 =     {'Db',     'Ebm',    'Fm',    'Gb',    'Ab',     'Bbm',    'Cdim'},
      Ionian_4 =     {'DbM7',   'Ebm7',   'Fm7',   'GbM7',  'Ab7',    'Bbm7',   'Cm7b5'},
      Dorian_3 =     {'Dbm',    'Ebm',    'Fb',    'Gb',    'Abm',    'Bbdim',  'Cb'},
      Dorian_4 =     {'Dbm7',   'Ebm7',   'FbM7',  'Gb7',   'Abm7',   'Bbm7b5', 'CbM7'},
      Phrygian_3 =   {'Dbm',    'Ebb',    'Fb',    'Gbm',   'Abdim',  'Bbb',    'Cbm'},
      Phrygian_4 =   {'Dbm7',   'EbbM7',  'Fb7',   'Gbm7',  'Abm7b5', 'BbbM7' , 'Cbm7'},
      Lydian_3 =     {'Db',     'Eb',     'Fm',    'Gdim',  'Ab',     'Bbm',    'Cm'},
      Lydian_4 =     {'DbM7',   'Eb7',    'Fm7',   'Gm7b5', 'AbM7',   'Bbm7',   'Cm7'},
      Mixolydian_3 = {'Db',     'Ebm',    'Fdim',  'Gb',    'Abm',    'Bbm',    'Cb'},
      Mixolydian_4 = {'Db7',    'Ebm7',   'Fm7b5', 'GbM7',  'Abm7',   'Bbm7',   'CbM7'},
      Aeolian_3 =    {'Dbm',    'Ebdim',  'Fb',    'Gbm',   'Abm',    'Bbb',    'Cb'},
      Aeolian_4 =    {'Dbm7',   'Ebm7b5', 'FbM7',  'Gbm7',  'Abm7',   'BbbM7',  'Cb7'},
      Locrian_3 =    {'Dbdim',  'Ebb',    'Fbm',   'Gbm',   'Abb',    'Bbb',    'Cbm'},
      Locrian_4 =    {'Dbm7b5', 'EbbM7',  'Fbm7',  'Gbm7',  'AbbM7',  'Bbb7',   'Cbm7'},
      Harmonic_3 =   {'Dbm',    'Ebdim',  'Fb+',   'Gbm',   'Ab',     'Bbb',    'Cdim'},
      Harmonic_4 =   {'DbmM7',  'Ebm7b5', 'Fb7+5', 'Gbm7',  'Ab7',    'BbbM7',  'Cdim'},
      Functional_3 = {'Dbm',    'Ebdim',  'Fb',    'Gbm',   'Ab',     'Bbb',    'Cdim'},
      Functional_4 = {'Dbm7',   'Ebm7b5', 'FbM7',  'Gbm7',  'Ab7',    'BbbM7',  'Cdim'},
    },
    ['D'] = { -- D, E, F#, G, A, B, C#
      Ionian_3 =     {'D',     'Em',    'F#m',     'G',      'A',     'Bm',    'C#dim'},
      Ionian_4 =     {'DM7',   'Em7',   'F#m7',    'GM7',    'A7',    'Bm7',   'C#m7b5'},
      Dorian_3 =     {'Dm',    'Em',    'F',     'G',      'Am',    'Bdim',  'C'},
      Dorian_4 =     {'Dm7',   'Em7',   'FM7',   'G7',     'Am7',   'Bm7b5', 'CM7'},
      Phrygian_3 =   {'Dm',    'Db',    'Eb',     'Fm',     'Gdim',  'Ab',    'Bbm'},
      Phrygian_4 =   {'Cm7',   'DbM7',  'Eb7',    'Fm7',    'Gm7b5', 'AbM7',  'Bbm7'},
      Lydian_3 =     {'C',     'D',     'Em',     'F#dim',  'G',     'Am',    'Bm'},
      Lydian_4 =     {'CM7',   'D7',    'Em7',    'F#m7b5', 'GM7',   'Am7',   'Bm7'},
      Mixolydian_3 = {'C',     'Dm',    'Edim',   'F',      'Gm',    'Am',    'Bb'},
      Mixolydian_4 = {'C7',    'Dm7',   'Em7b5',  'FM7',    'Gm7',   'Am7',   'BbM7'},
      Aeolian_3 =    {'Cm',    'Ddim',  'Eb',     'Fm',     'Gm',    'Ab',    'Bb'},
      Aeolian_4 =    {'Cm7',   'Dm7b5', 'EbM7',   'Fm7',    'Gm7',   'AbM7',  'Bb7'},
      Locrian_3 =    {'Cdim',  'Db',    'Ebm',    'Fm',     'Gb',    'Ab',    'Bbm'},
      Locrian_4 =    {'Cm7b5', 'DbM7',  'Ebm7',   'Fm7',    'GbM7',  'Ab7',   'Bbm7'},
      Harmonic_3 =   {'Cm',    'Ddim',  'Eb+',    'Fm',     'G',     'Ab',    'Bdim'},
      Harmonic_4 =   {'CmM7',  'Dm7b5', 'EbM7+5', 'Fm7',    'G7',    'AbM7',  'Bdim'},
      Functional_3 = {'Cm',    'Ddim',  'Eb',     'Fm',     'G',     'Ab',    'Bdim'},
      Functional_4 = {'Cm7',   'Dm7b5', 'EbM7',   'Fm7',    'G7',    'AbM7',  'Bdim'},
    }
  }

  local grid = an['key_field_' .. key_field].key_grid
  for i, j, c in grid:grid_pairs() do
    for k, sc in pairs(index_to_static_content) do
      if k[1] == i and k[2] == j then
        c.content = sc
      end
    end
    if i == 1 and j == 1 then
      c.content = key
    elseif i > 1 and j > 1 then
      c.content = key_to_chords[key][index_to_mode[j] .. '_4'][i-1]
    end
  end
end
