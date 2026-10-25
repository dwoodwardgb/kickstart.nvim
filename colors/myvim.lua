-- Name:         myvim
-- Description:  A stripped-down version of Vim's default color scheme.
--               Tuned for gui colors, with approximate 16-color cterm
--               fallbacks, and treesitter/LSP groups collapsed down so that
--               only a few things get color:
--                 operators      red, bold
--                 keywords       grey + bold (light) / yellow (dark)
--                 strings        magenta
--                 types/classes  green
--                 functions      cyan
--                 comments       blue
--               Everything else falls back to the normal foreground.

vim.cmd.highlight('clear')
vim.g.colors_name = 'myvim'

local light = vim.o.background == 'light'

-- Colors are taken straight from the `vim` scheme: Blue comments, Magenta
-- constants, Brown statements/operators, DarkCyan identifiers, SeaGreen types.
local c = light and {
  fg        = '#000000',
  bg        = '#ffffff',
  comment   = '#0000ff', -- Blue
  string    = '#ff00ff', -- Magenta
  operator  = '#a52a2a', -- Brown
  func      = '#008b8b', -- DarkCyan
  type      = '#2e8b57', -- SeaGreen
  keyword   = '#4a4a4a', -- grey, so keywords recede
  subtle    = '#000000', -- black line numbers, rather than vim's Brown
  faint     = '#d3d3d3', -- LightGrey
  fainter   = '#e5e5e5', -- Grey90
  red       = '#ff0000',
  orange    = '#ffa500',
  blue      = '#0000ff',
  green     = '#2e8b57',
  search    = '#ffff00', -- Yellow
  grey      = '#808080',
  cursorline = '#eaf2fc', -- faint blue wash for the current row
  visual     = '#add6ff', -- stronger blue for selections, as in VSCode
  search_fg  = '#000000',
  cursearch    = '#ffa500', -- bright orange, so the current match pops against the yellow of other matches
  cursearch_fg = '#000000',
} or {
  fg        = '#ffffff',
  bg        = '#000000',
  comment   = '#80a0ff',
  string    = '#ffa0a0',
  operator  = '#ff6060',
  func      = '#40ffff',
  type      = '#60ff60',
  keyword   = '#ffff60', -- Yellow, as in the original vim scheme
  subtle    = '#ffffff', -- white line numbers, rather than vim's Yellow
  faint     = '#585858', -- DarkGrey
  fainter   = '#3a3a3a',
  red       = '#ff0000',
  orange    = '#ffa500',
  blue      = '#80a0ff',
  green     = '#60ff60',
  search    = '#6b5300', -- dim gold, as in nvim's built-in dark 'default' scheme
  grey      = '#a0a0a0',
  cursorline = '#16212e', -- faint blue wash for the current row
  visual     = '#264f78', -- stronger blue for selections, as in VSCode
  search_fg  = '#eef1f8', -- near-white, as in nvim's built-in dark 'default' scheme
  cursearch    = '#fce094', -- bright yellow, so the current match pops against the dim gold of other matches
  cursearch_fg = '#07080d',
}

-- Nearest of the basic 16 terminal colors for every hex used above, so that the
-- scheme degrades sensibly without truecolor. Anything not listed here simply
-- gets no cterm color and falls back to the terminal's own default.
--   0 black   1 red      2 green   3 yellow  4 blue   5 magenta  6 cyan   7 grey
--   8 dkgrey  9 brred   10 brgreen 11 bryell 12 brblue 13 brmag  14 brcyan 15 white
local term = {
  -- light palette
  ['#000000'] = 0,  -- fg / line numbers
  ['#ffffff'] = 15, -- bg
  ['#0000ff'] = 4,  -- Blue comments
  ['#ff00ff'] = 5,  -- Magenta strings
  ['#a52a2a'] = 1,  -- Brown operators
  ['#008b8b'] = 6,  -- DarkCyan functions
  ['#2e8b57'] = 2,  -- SeaGreen types
  ['#4a4a4a'] = 8,  -- grey keywords
  ['#d3d3d3'] = 7,
  ['#e5e5e5'] = 7,
  -- these two cheat outside the basic 16, since nothing in that range gives a
  -- faint enough wash for the current row or a light enough blue for selections
  ['#eaf2fc'] = 255, -- current row
  ['#add6ff'] = 153, -- selection
  ['#808080'] = 8,
  ['#00ffff'] = 14, -- Cyan MatchParen
  -- dark palette
  ['#80a0ff'] = 12, -- comments
  ['#ffa0a0'] = 13, -- strings
  ['#ff6060'] = 9,  -- operators
  ['#40ffff'] = 14, -- functions
  ['#60ff60'] = 10, -- types
  ['#ffff60'] = 11, -- keywords
  ['#585858'] = 8,
  ['#3a3a3a'] = 8,
  ['#16212e'] = 8,  -- current row
  ['#264f78'] = 4,  -- selection
  ['#a0a0a0'] = 7,
  -- shared
  ['#ff0000'] = 9,
  ['#ffa500'] = 3,
  ['#ffff00'] = 11,
  ['#6b5300'] = 3,  -- dim gold: search bg (dark)
  ['#eef1f8'] = 15, -- near-white: search fg (dark)
  ['#fce094'] = 11, -- bright pale yellow cursearch bg (dark)
  ['#07080d'] = 0,  -- near-black cursearch fg (dark)
  -- diff washes, which only ever appear as backgrounds
  ['#e2f3e2'] = 2, ['#eef0f8'] = 4, ['#cfe6cf'] = 6, ['#f8e8e8'] = 1,
  ['#1e2e1e'] = 2, ['#22262e'] = 4, ['#2a402a'] = 6, ['#2e1e1e'] = 1,
}

-- Attributes that are meaningful in a terminal too, unlike e.g. `blend`.
local term_attrs = { 'bold', 'italic', 'underline', 'undercurl', 'strikethrough', 'reverse' }

local function hi(name, val)
  val.force = true

  -- Derive the cterm colors from the gui ones rather than hand-maintaining a
  -- parallel set of definitions.
  val.ctermfg = val.ctermfg or term[val.fg]
  val.ctermbg = val.ctermbg or term[val.bg]

  val.cterm = val.cterm or {}
  for _, attr in ipairs(term_attrs) do
    if val[attr] then
      val.cterm[attr] = true
    end
  end

  vim.api.nvim_set_hl(0, name, val)
end

--stylua: ignore start

-- UI ------------------------------------------------------------------------
hi('Normal',          { fg = c.fg, bg = c.bg })
hi('NormalNC',        { link = 'Normal' })
hi('Cursor',          { fg = c.bg, bg = c.fg })
hi('lCursor',         { link = 'Cursor' })
hi('TermCursor',      { link = 'Cursor' })
hi('CursorLine',      { bg = c.cursorline })
hi('CursorColumn',    { link = 'CursorLine' })
hi('ColorColumn',     { bg = c.fainter })
hi('LineNr',          { fg = c.subtle })
hi('LineNrAbove',     { link = 'LineNr' })
hi('LineNrBelow',     { link = 'LineNr' })
hi('CursorLineNr',    { fg = c.subtle })
hi('SignColumn',      { fg = c.subtle, bg = c.bg })
hi('CursorLineSign',  { link = 'SignColumn' })
hi('FoldColumn',      { fg = c.subtle, bg = c.bg })
hi('CursorLineFold',  { link = 'FoldColumn' })
hi('Folded',          { fg = c.grey, bg = c.faint })
hi('VertSplit',       { fg = c.faint })
hi('WinSeparator',    { link = 'VertSplit' })
hi('NonText',         { fg = c.grey })
hi('EndOfBuffer',     { link = 'NonText' })
hi('Whitespace',      { link = 'NonText' })
hi('SpecialKey',      { fg = c.grey })
hi('Conceal',         { fg = c.grey })
hi('MatchParen',      { bg = light and '#00ffff' or '#008b8b' }) -- Cyan / DarkCyan
hi('Visual',          { bg = c.visual })
hi('VisualNOS',       { link = 'Visual' })
hi('Search',          { fg = c.search_fg, bg = c.search })
hi('CurSearch',       { fg = c.cursearch_fg, bg = c.cursearch })
hi('IncSearch',       { link = 'CurSearch' })
hi('Substitute',      { link = 'Search' })
hi('QuickFixLine',    { link = 'Search' })
hi('Directory',       { fg = c.blue })
hi('Title',           { fg = c.string })
hi('Question',        { fg = c.green })
hi('MoreMsg',         { fg = c.green })
hi('ModeMsg',         { fg = c.fg })
hi('MsgArea',         { link = 'Normal' })
hi('MsgSeparator',    { link = 'StatusLine' })
hi('WarningMsg',      { fg = c.orange })
hi('ErrorMsg',        { fg = c.red })
hi('Error',           { fg = c.red })
hi('Todo',            { fg = c.fg, bg = c.faint })
hi('StatusLine',      { fg = c.fg, bg = c.faint })
hi('StatusLineNC',    { fg = c.grey, bg = c.fainter })
hi('StatusLineTerm',  { link = 'StatusLine' })
hi('StatusLineTermNC',{ link = 'StatusLineNC' })
hi('WinBar',          { fg = c.grey, bg = c.bg })
hi('WinBarNC',        { link = 'WinBar' })
hi('TabLine',         { fg = c.grey, bg = c.fainter })
hi('TabLineFill',     { bg = c.fainter })
hi('TabLineSel',      { fg = c.fg, bg = c.bg })
hi('Pmenu',           { fg = c.fg, bg = c.faint })
hi('PmenuSel',        { fg = c.bg, bg = c.fg })
hi('PmenuSbar',       { bg = c.faint })
hi('PmenuThumb',      { bg = c.grey })
hi('PmenuKind',       { link = 'Pmenu' })
hi('PmenuKindSel',    { link = 'PmenuSel' })
hi('PmenuMatch',      { fg = c.func, bg = c.faint })
hi('PmenuMatchSel',   { link = 'PmenuSel' })
hi('PmenuExtra',      { fg = c.grey, bg = c.faint })
hi('PmenuExtraSel',   { link = 'PmenuSel' })
hi('NormalFloat',     { fg = c.fg, bg = c.bg })
hi('FloatBorder',     { fg = c.grey, bg = c.bg })
hi('FloatTitle',      { fg = c.fg, bg = c.bg })
hi('FloatFooter',     { link = 'FloatTitle' })
hi('FloatShadow',     { bg = '#000000', blend = 80 })
hi('FloatShadowThrough', { bg = '#000000', blend = 100 })
hi('WildMenu',        { link = 'PmenuSel' })
hi('ComplMatchIns',   {})
hi('ComplHint',       { link = 'NonText' })
hi('ComplHintMore',   { link = 'NonText' })
hi('SnippetTabstop',  { link = 'Visual' })
hi('SnippetTabstopActive', { link = 'Visual' })
hi('Underlined',      { underline = true })
hi('Ignore',          { fg = c.grey })

-- Diff ----------------------------------------------------------------------
hi('DiffAdd',         { bg = light and '#e2f3e2' or '#1e2e1e' })
hi('DiffChange',      { bg = light and '#eef0f8' or '#22262e' })
hi('DiffText',        { bg = light and '#cfe6cf' or '#2a402a' })
hi('DiffTextAdd',     { link = 'DiffText' })
hi('DiffDelete',      { fg = c.grey, bg = light and '#f8e8e8' or '#2e1e1e' })
hi('Added',           { fg = c.green })
hi('Changed',         { fg = c.blue })
hi('Removed',         { fg = c.red })

-- Diagnostics ---------------------------------------------------------------
hi('DiagnosticError', { fg = c.red })
hi('DiagnosticWarn',  { fg = c.orange })
hi('DiagnosticInfo',  { fg = c.blue })
hi('DiagnosticHint',  { fg = c.grey })
hi('DiagnosticOk',    { fg = c.green })
hi('DiagnosticUnderlineError', { sp = c.red,    undercurl = true })
hi('DiagnosticUnderlineWarn',  { sp = c.orange, undercurl = true })
hi('DiagnosticUnderlineInfo',  { sp = c.blue,   undercurl = true })
hi('DiagnosticUnderlineHint',  { sp = c.grey, undercurl = true })
hi('DiagnosticUnderlineOk',    { sp = c.green,  undercurl = true })
for _, kind in ipairs({ 'Error', 'Warn', 'Info', 'Hint', 'Ok' }) do
  for _, style in ipairs({ 'VirtualText', 'Floating', 'Sign' }) do
    hi('Diagnostic' .. style .. kind, { link = 'Diagnostic' .. kind })
  end
end
hi('DiagnosticDeprecated',  { sp = c.red, strikethrough = true })
hi('DiagnosticUnnecessary', { link = 'Comment' })
hi('LspInlayHint',          { fg = c.grey })
hi('LspReferenceText',      { bg = c.faint })
hi('LspReferenceRead',      { link = 'LspReferenceText' })
hi('LspReferenceWrite',     { link = 'LspReferenceText' })
hi('LspSignatureActiveParameter', { underline = true })
hi('SpellBad',   { sp = c.red,    undercurl = true })
hi('SpellCap',   { sp = c.blue,   undercurl = true })
hi('SpellLocal', { sp = c.blue,   undercurl = true })
hi('SpellRare',  { sp = c.grey, undercurl = true })

-- Syntax: the only colored things are comments, strings/constants,
-- operators, functions, and types. Everything else is plain fg.
hi('Comment',        { fg = c.comment })
hi('Constant',       { fg = c.string })
hi('String',         { link = 'Constant' })
hi('Character',      { link = 'Constant' })
hi('Number',         { link = 'Constant' })
hi('Float',          { link = 'Constant' })
hi('Boolean',        { link = 'Constant' })
hi('Identifier',     { fg = c.fg })
hi('Function',       { fg = c.func })
hi('Statement',      { fg = c.keyword, bold = light }) -- bold only in light mode
hi('Conditional',    { link = 'Statement' })
hi('Repeat',         { link = 'Statement' })
hi('Label',          { link = 'Statement' })
hi('Keyword',        { link = 'Statement' })
hi('Exception',      { link = 'Statement' })
hi('Operator',       { fg = c.operator, bold = true })
hi('PreProc',        { fg = c.fg })
hi('Include',        { link = 'PreProc' })
hi('Define',         { link = 'PreProc' })
hi('Macro',          { link = 'PreProc' })
hi('PreCondit',      { link = 'PreProc' })
hi('Type',           { fg = c.type })
hi('StorageClass',   { link = 'Statement' })
hi('Structure',      { link = 'Type' })
hi('Typedef',        { link = 'Type' })
hi('Special',        { fg = c.fg })
hi('SpecialChar',    { fg = c.string })
hi('Tag',            { fg = c.fg })
hi('Delimiter',      { fg = c.fg })
hi('SpecialComment', { link = 'Comment' })
hi('Debug',          { fg = c.fg })

-- Treesitter ----------------------------------------------------------------
-- Rather than mirroring every capture, clear most of them to plain fg and
-- only keep color on the handful listed above.
hi('@comment',                    { link = 'Comment' })
hi('@comment.documentation',      { link = 'Comment' })
hi('@comment.todo',               { link = 'Todo' })
hi('@comment.note',               { link = 'Comment' })
hi('@comment.warning',            { fg = c.orange })
hi('@comment.error',              { fg = c.red })

hi('@string',                     { link = 'String' })
hi('@string.documentation',       { link = 'Comment' })
hi('@string.regexp',              { link = 'String' })
hi('@string.escape',              { link = 'SpecialChar' })
hi('@string.special',             { link = 'SpecialChar' })
hi('@string.special.url',         { fg = c.string, underline = true })
hi('@character',                  { link = 'Constant' })
hi('@character.special',          { link = 'SpecialChar' })
hi('@number',                     { link = 'Constant' })
hi('@number.float',               { link = 'Constant' })
hi('@boolean',                    { link = 'Constant' })
hi('@constant',                   { fg = c.fg })
hi('@constant.builtin',           { fg = c.fg })
hi('@constant.macro',             { fg = c.fg })

hi('@function',                   { link = 'Function' })
hi('@function.builtin',           { link = 'Function' })
hi('@function.call',              { link = 'Function' })
hi('@function.macro',             { link = 'Function' })
hi('@function.method',            { link = 'Function' })
hi('@function.method.call',       { link = 'Function' })
hi('@constructor',                { link = 'Type' })
hi('@type',                       { link = 'Type' })
hi('@type.builtin',               { link = 'Type' })
hi('@type.definition',            { link = 'Type' })
hi('@type.qualifier',             { link = 'Statement' })
hi('@attribute',                  { fg = c.fg })
hi('@attribute.builtin',          { fg = c.fg })

hi('@variable',                   { fg = c.fg })
hi('@variable.builtin',           { fg = c.fg })
hi('@variable.parameter',         { fg = c.fg })
hi('@variable.parameter.builtin', { fg = c.fg })
hi('@variable.member',            { fg = c.fg })
hi('@property',                   { fg = c.fg })
hi('@field',                      { fg = c.fg })
hi('@module',                     { fg = c.fg })
hi('@module.builtin',             { fg = c.fg })
hi('@label',                      { fg = c.fg })
hi('@namespace',                  { fg = c.fg })

hi('@keyword',                    { link = 'Statement' })
hi('@keyword.conditional',        { link = 'Statement' })
hi('@keyword.conditional.ternary',{ link = 'Operator' })
hi('@keyword.coroutine',          { link = 'Statement' })
hi('@keyword.debug',              { link = 'Statement' })
hi('@keyword.directive',          { link = 'Statement' })
hi('@keyword.directive.define',   { link = 'Statement' })
hi('@keyword.exception',          { link = 'Statement' })
hi('@keyword.function',           { link = 'Statement' })
hi('@keyword.import',             { link = 'Statement' })
hi('@keyword.modifier',           { link = 'Statement' })
hi('@keyword.operator',           { link = 'Operator' })
hi('@keyword.repeat',             { link = 'Statement' })
hi('@keyword.return',             { link = 'Statement' })
hi('@keyword.type',               { link = 'Statement' })
hi('@operator',                   { link = 'Operator' })

hi('@punctuation',                { fg = c.fg })
hi('@punctuation.delimiter',      { fg = c.fg })
hi('@punctuation.bracket',        { fg = c.fg })
hi('@punctuation.special',        { fg = c.fg })

hi('@tag',                        { fg = c.fg })
hi('@tag.builtin',                { fg = c.fg })
hi('@tag.attribute',             { fg = c.fg })
hi('@tag.delimiter',              { fg = c.fg })

-- Markup: keep it quiet, lean on structure rather than color.
hi('@markup',                     { fg = c.fg })
hi('@markup.strong',              {})
hi('@markup.italic',              { italic = true })
hi('@markup.strikethrough',       { strikethrough = true })
hi('@markup.underline',           { underline = true })
hi('@markup.heading',             { fg = c.fg })
hi('@markup.quote',               { fg = c.grey })
hi('@markup.math',                { fg = c.fg })
hi('@markup.link',                { fg = c.fg })
hi('@markup.link.label',          { fg = c.fg })
hi('@markup.link.url',            { fg = c.grey, underline = true })
hi('@markup.raw',                 { fg = c.string })
hi('@markup.raw.block',           { fg = c.fg })
hi('@markup.list',                { fg = c.fg })
hi('@markup.list.checked',        { fg = c.green })
hi('@markup.list.unchecked',      { fg = c.fg })
hi('@diff.plus',                  { link = 'Added' })
hi('@diff.minus',                 { link = 'Removed' })
hi('@diff.delta',                 { link = 'Changed' })

-- LSP semantic tokens ------------------------------------------------------
hi('@lsp.type.class',         { link = 'Type' })
hi('@lsp.type.enum',          { link = 'Type' })
hi('@lsp.type.interface',     { link = 'Type' })
hi('@lsp.type.struct',        { link = 'Type' })
hi('@lsp.type.type',          { link = 'Type' })
hi('@lsp.type.typeParameter', { link = 'Type' })
hi('@lsp.type.function',      { link = 'Function' })
hi('@lsp.type.method',        { link = 'Function' })
hi('@lsp.type.decorator',     { fg = c.fg })
hi('@lsp.type.macro',         { fg = c.fg })
hi('@lsp.type.comment',       { link = 'Comment' })
hi('@lsp.type.string',        { link = 'String' })
hi('@lsp.type.number',        { link = 'Constant' })
hi('@lsp.type.keyword',       { link = 'Statement' })
hi('@lsp.type.operator',      { link = 'Operator' })
hi('@lsp.type.namespace',     { fg = c.fg })
hi('@lsp.type.enumMember',    { fg = c.fg })
hi('@lsp.type.parameter',     { fg = c.fg })
hi('@lsp.type.property',      { fg = c.fg })
hi('@lsp.type.variable',      { fg = c.fg })
hi('@lsp.mod.readonly',       {})
hi('@lsp.mod.deprecated',     { strikethrough = true })
hi('@lsp.typemod.function.defaultLibrary', { link = 'Function' })
hi('@lsp.typemod.method.defaultLibrary',   { link = 'Function' })
hi('@lsp.typemod.variable.defaultLibrary', { fg = c.fg })
--stylua: ignore end
