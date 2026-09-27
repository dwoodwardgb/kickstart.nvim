-- standard.lua --- Neovim port of Protesilaos' `standard-themes`.
--
-- "Like the unthemed Emacs, but more consistent." A single colorscheme
-- with light and dark variants: it follows `background`, so switch with
-- `:set background=light` / `:set background=dark`. Aware of Tree-sitter
-- and Telescope, which are used in this config.
--
-- Usage: `:colorscheme standard`, then toggle `:set background=...`.

-- Light palette, from standard-light-theme.el.
local light = {
  p = {
    bg_main = "#ffffff", fg_main = "#000000", bg_dim = "#ebebeb",
    fg_dim = "#7f7f7f", bg_alt = "#dcdcdc", fg_alt = "#193f8f",
    bg_active = "#bfbfbf", bg_inactive = "#f0f0f0", border = "#bababa",
    red = "#b3303a", red_warmer = "#e00033", red_cooler = "#ce2b50", red_faint = "#b22222",
    green = "#228b22", green_warmer = "#4f7400", green_cooler = "#008858", green_faint = "#61756c",
    yellow = "#a45f22", yellow_warmer = "#b6532f", yellow_cooler = "#a0522d", yellow_faint = "#76502a",
    blue = "#001faf", blue_warmer = "#3a5fcd", blue_cooler = "#0000ff", blue_faint = "#483d8b",
    magenta = "#721045", magenta_warmer = "#8b2252", magenta_cooler = "#800080", magenta_faint = "#8f4499",
    cyan = "#1f6fbf", cyan_warmer = "#2f8fab", cyan_cooler = "#008b8b", cyan_faint = "#3f7a80",
    bg_red_intense = "#ff8f88", bg_green_intense = "#8adf80", bg_yellow_intense = "#f3d000",
    bg_blue_intense = "#bfc9ff", bg_magenta_intense = "#dfa0f0", bg_cyan_intense = "#a4d5f9",
    bg_red_subtle = "#ffcfbf", bg_green_subtle = "#b3fabf", bg_yellow_subtle = "#fff576",
    bg_blue_subtle = "#ccdfff", bg_magenta_subtle = "#ffddff", bg_cyan_subtle = "#bfefff",
    bg_added = "#c0f8d0", fg_added = "#007200", bg_changed = "#ffdfa9", fg_changed = "#8d6a12",
    bg_removed = "#ffd8d5", fg_removed = "#a02a2a",
    bg_completion = "#bfe8ff", bg_popup = "#f3f3f3", bg_hover = "#aaeccf",
    bg_hl_line = "#b4eeb4", bg_region = "#eedc82", bg_paren = "#40e0d0",
    bg_mode_line_active = "#b3b3b3", fg_mode_line_active = "#000000", border_mode_line_active = "#5a5a5a",
    bg_mode_line_inactive = "#e5e5e5", fg_mode_line_inactive = "#7f7f7f",
    modeline_err = "#b02020", modeline_warning = "#5f1080", modeline_info = "#002fb0",
  },
  m = {
    err = "red_warmer", warning = "yellow_warmer", info = "green", fg_prompt = "blue_cooler",
    builtin = "blue_faint", comment = "red_faint", constant = "cyan_cooler",
    fnname = "blue_cooler", fnname_call = "blue_faint", keyword = "magenta_cooler",
    preprocessor = "blue_faint", docstring = "magenta_warmer", string = "magenta_warmer",
    type = "green", variable = "yellow_cooler", variable_use = "yellow_faint",
    rx_backslash = "green", rx_construct = "fg_main", accent_0 = "blue", accent_1 = "red_cooler",
    accent_2 = "green", accent_3 = "magenta_cooler", fg_link = "blue_warmer",
    fg_link_visited = "magenta", keybind = "blue",
  },
}

-- Dark palette, from standard-dark-theme.el.
local dark = {
  p = {
    bg_main = "#000000", fg_main = "#ffffff", bg_dim = "#272727",
    fg_dim = "#a6a6a6", bg_alt = "#363636", fg_alt = "#a0afef",
    bg_active = "#606060", bg_inactive = "#202020", border = "#606070",
    red = "#ff6f60", red_warmer = "#ff7f24", red_cooler = "#ff778f", red_faint = "#ee5c42",
    green = "#44cc44", green_warmer = "#7abd0f", green_cooler = "#98fb98", green_faint = "#61a06c",
    yellow = "#eedd82", yellow_warmer = "#fec43f", yellow_cooler = "#ffa07a", yellow_faint = "#dfb08f",
    blue = "#87ceff", blue_warmer = "#80aaff", blue_cooler = "#02cfff", blue_faint = "#b0c4de",
    magenta = "#df8faf", magenta_warmer = "#ff8fe7", magenta_cooler = "#ce82ff", magenta_faint = "#efafdf",
    cyan = "#00ffff", cyan_warmer = "#87cefa", cyan_cooler = "#7fffd4", cyan_faint = "#6acbcb",
    bg_red_intense = "#9d1f1f", bg_green_intense = "#2f822f", bg_yellow_intense = "#7a6100",
    bg_blue_intense = "#1640b0", bg_magenta_intense = "#7030af", bg_cyan_intense = "#2266ae",
    bg_red_subtle = "#620f2a", bg_green_subtle = "#00422a", bg_yellow_subtle = "#4a4000",
    bg_blue_subtle = "#242679", bg_magenta_subtle = "#552f5f", bg_cyan_subtle = "#004065",
    bg_added = "#00331f", fg_added = "#4fb04f", bg_changed = "#323200", fg_changed = "#e0cf03",
    bg_removed = "#4a1119", fg_removed = "#ff5f5f",
    bg_completion = "#254b5f", bg_popup = "#0c0c0c", bg_hover = "#457b2f",
    bg_hl_line = "#334815", bg_region = "#20009d", bg_paren = "#4f94cd",
    bg_mode_line_active = "#505050", fg_mode_line_active = "#ffffff", border_mode_line_active = "#959595",
    bg_mode_line_inactive = "#323232", fg_mode_line_inactive = "#a6a6a6",
    modeline_err = "#ff80af", modeline_warning = "#dfcf33", modeline_info = "#2fc82f",
  },
  m = {
    err = "red", warning = "yellow_warmer", info = "green", fg_prompt = "blue",
    builtin = "blue_faint", comment = "red_warmer", constant = "cyan_cooler",
    fnname = "cyan_warmer", fnname_call = "cyan_faint", keyword = "cyan",
    preprocessor = "blue_faint", docstring = "yellow_cooler", string = "yellow_cooler",
    type = "green_cooler", variable = "yellow", variable_use = "yellow_faint",
    rx_backslash = "green", rx_construct = "fg_main", accent_0 = "blue_warmer", accent_1 = "red_cooler",
    accent_2 = "green", accent_3 = "magenta_cooler", fg_link = "cyan",
    fg_link_visited = "magenta_cooler", keybind = "blue_cooler",
  },
}

local function apply()
  local variant = vim.o.background == "light" and light or dark
  local p = variant.p
  -- Resolve semantic mappings (mapping name -> palette color name) to hex.
  local s = {}
  for name, color in pairs(variant.m) do
    s[name] = p[color]
  end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "standard"

  local groups = {
    -- Editor UI
    Normal       = { fg = p.fg_main, bg = p.bg_main },
    NormalFloat  = { fg = p.fg_main, bg = p.bg_popup },
    FloatBorder  = { fg = p.border, bg = p.bg_popup },
    FloatTitle   = { fg = p.fg_main, bg = p.bg_popup, bold = true },
    Cursor       = { fg = p.bg_main, bg = s.cursor or p.fg_main },
    CursorLine   = { bg = p.bg_hl_line },
    CursorColumn = { bg = p.bg_hl_line },
    ColorColumn  = { bg = p.bg_dim },
    CursorLineNr = { fg = p.fg_main, bold = true },
    LineNr       = { fg = p.fg_dim },
    SignColumn   = { bg = p.bg_main },
    Folded       = { fg = p.fg_dim, bg = p.bg_dim },
    FoldColumn   = { fg = p.fg_dim },
    VertSplit    = { fg = p.border },
    WinSeparator = { fg = p.border },
    Visual       = { bg = p.bg_region },
    VisualNOS    = { bg = p.bg_region },
    Search       = { bg = p.bg_yellow_subtle, fg = p.fg_main },
    IncSearch    = { bg = p.bg_yellow_intense, fg = p.fg_main },
    CurSearch    = { bg = p.bg_yellow_intense, fg = p.fg_main },
    MatchParen   = { bg = p.bg_paren, bold = true },
    NonText      = { fg = p.fg_dim },
    Whitespace   = { fg = p.bg_active },
    SpecialKey   = { fg = p.fg_dim },
    Directory    = { fg = s.accent_0 },
    Title        = { fg = s.accent_0, bold = true },
    ErrorMsg     = { fg = s.err },
    WarningMsg   = { fg = s.warning },
    MoreMsg      = { fg = s.info },
    ModeMsg      = { fg = p.fg_main, bold = true },
    Question     = { fg = s.info },
    QuickFixLine = { bg = p.bg_hl_line },
    WildMenu     = { bg = p.bg_completion },

    -- Statusline / tabline
    StatusLine   = { fg = p.fg_mode_line_active, bg = p.bg_mode_line_active },
    StatusLineNC = { fg = p.fg_mode_line_inactive, bg = p.bg_mode_line_inactive },
    TabLine      = { fg = p.fg_mode_line_inactive, bg = p.bg_mode_line_inactive },
    TabLineSel   = { fg = p.fg_mode_line_active, bg = p.bg_mode_line_active, bold = true },
    TabLineFill  = { bg = p.bg_inactive },

    -- Popup menu / completion
    Pmenu        = { fg = p.fg_main, bg = p.bg_popup },
    PmenuSel     = { bg = p.bg_completion, fg = p.fg_main },
    PmenuSbar    = { bg = p.bg_active },
    PmenuThumb   = { bg = p.fg_dim },

    -- Diff
    DiffAdd      = { bg = p.bg_added, fg = p.fg_main },
    DiffChange   = { bg = p.bg_changed, fg = p.fg_main },
    DiffDelete   = { bg = p.bg_removed, fg = p.fg_main },
    DiffText     = { bg = p.bg_changed, fg = p.fg_main, bold = true },
    Added        = { fg = p.fg_added },
    Changed      = { fg = p.fg_changed },
    Removed      = { fg = p.fg_removed },

    -- Spell
    SpellBad     = { sp = s.err, undercurl = true },
    SpellCap     = { sp = s.warning, undercurl = true },
    SpellRare    = { sp = s.info, undercurl = true },
    SpellLocal   = { sp = s.info, undercurl = true },

    -- Legacy syntax groups
    Comment      = { fg = s.comment, italic = true },
    Constant     = { fg = s.constant },
    String       = { fg = s.string },
    Character    = { fg = s.string },
    Number       = { fg = s.constant },
    Boolean      = { fg = s.constant },
    Float        = { fg = s.constant },
    Identifier   = { fg = s.variable },
    Function     = { fg = s.fnname },
    Statement    = { fg = s.keyword },
    Conditional  = { fg = s.keyword },
    Repeat       = { fg = s.keyword },
    Label        = { fg = s.keyword },
    Operator     = { fg = p.fg_main },
    Keyword      = { fg = s.keyword },
    Exception    = { fg = s.keyword },
    PreProc      = { fg = s.preprocessor },
    Include      = { fg = s.preprocessor },
    Define       = { fg = s.preprocessor },
    Macro        = { fg = s.preprocessor },
    PreCondit    = { fg = s.preprocessor },
    Type         = { fg = s.type },
    StorageClass = { fg = s.type },
    Structure    = { fg = s.type },
    Typedef      = { fg = s.type },
    Special      = { fg = s.accent_3 },
    SpecialChar  = { fg = s.rx_backslash },
    Tag          = { fg = s.accent_1 },
    Delimiter    = { fg = p.fg_main },
    SpecialComment = { fg = s.comment, bold = true },
    Debug        = { fg = s.err },
    Underlined   = { fg = s.fg_link, underline = true },
    Ignore       = { fg = p.fg_dim },
    Error        = { fg = s.err, bold = true },
    Todo         = { fg = p.fg_main, bg = p.bg_yellow_subtle, bold = true },

    -- Tree-sitter
    ["@comment"]              = { link = "Comment" },
    ["@comment.documentation"] = { fg = s.docstring },
    ["@comment.error"]        = { fg = s.err },
    ["@comment.warning"]      = { fg = s.warning },
    ["@comment.note"]         = { fg = s.info },
    ["@comment.todo"]         = { link = "Todo" },
    ["@variable"]             = { fg = s.variable },
    ["@variable.builtin"]     = { fg = s.builtin },
    ["@variable.parameter"]   = { fg = s.variable_use },
    ["@variable.member"]      = { fg = s.variable_use },
    ["@constant"]             = { fg = s.constant },
    ["@constant.builtin"]     = { fg = s.builtin },
    ["@constant.macro"]       = { fg = s.preprocessor },
    ["@module"]               = { fg = s.type },
    ["@label"]                = { fg = s.keyword },
    ["@string"]               = { fg = s.string },
    ["@string.documentation"] = { fg = s.docstring },
    ["@string.regexp"]        = { fg = s.rx_construct },
    ["@string.escape"]        = { fg = s.rx_backslash },
    ["@string.special"]       = { fg = s.accent_3 },
    ["@character"]            = { fg = s.string },
    ["@character.special"]    = { fg = s.rx_backslash },
    ["@boolean"]              = { fg = s.constant },
    ["@number"]               = { fg = s.constant },
    ["@number.float"]         = { fg = s.constant },
    ["@function"]             = { fg = s.fnname },
    ["@function.builtin"]     = { fg = s.builtin },
    ["@function.call"]        = { fg = s.fnname_call },
    ["@function.macro"]       = { fg = s.preprocessor },
    ["@function.method"]      = { fg = s.fnname },
    ["@function.method.call"] = { fg = s.fnname_call },
    ["@constructor"]          = { fg = s.type },
    ["@operator"]             = { fg = p.fg_main },
    ["@keyword"]              = { fg = s.keyword },
    ["@keyword.function"]     = { fg = s.keyword },
    ["@keyword.operator"]     = { fg = s.keyword },
    ["@keyword.return"]       = { fg = s.keyword },
    ["@keyword.import"]       = { fg = s.preprocessor },
    ["@keyword.conditional"]  = { fg = s.keyword },
    ["@keyword.repeat"]       = { fg = s.keyword },
    ["@keyword.exception"]    = { fg = s.keyword },
    ["@keyword.directive"]    = { fg = s.preprocessor },
    ["@type"]                 = { fg = s.type },
    ["@type.builtin"]         = { fg = s.type },
    ["@type.definition"]      = { fg = s.type },
    ["@attribute"]            = { fg = s.preprocessor },
    ["@property"]             = { fg = s.variable_use },
    ["@field"]                = { fg = s.variable_use },
    ["@punctuation.delimiter"] = { fg = p.fg_main },
    ["@punctuation.bracket"]  = { fg = p.fg_main },
    ["@punctuation.special"]  = { fg = s.accent_3 },
    ["@tag"]                  = { fg = s.keyword },
    ["@tag.attribute"]        = { fg = s.variable },
    ["@tag.delimiter"]        = { fg = p.fg_main },
    -- Markup (markdown, etc.)
    ["@markup.heading"]       = { fg = s.accent_0, bold = true },
    ["@markup.strong"]        = { bold = true },
    ["@markup.italic"]        = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.link"]          = { fg = s.fg_link, underline = true },
    ["@markup.link.url"]      = { fg = s.fg_link, underline = true },
    ["@markup.raw"]           = { fg = s.string },
    ["@markup.list"]          = { fg = s.accent_1 },
    ["@markup.quote"]         = { fg = s.docstring, italic = true },
    ["@diff.plus"]            = { fg = p.fg_added },
    ["@diff.minus"]           = { fg = p.fg_removed },
    ["@diff.delta"]           = { fg = p.fg_changed },

    -- LSP semantic tokens (follow Tree-sitter)
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.function"]  = { link = "@function" },
    ["@lsp.type.method"]    = { link = "@function.method" },
    ["@lsp.type.variable"]  = { link = "@variable" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.property"]  = { link = "@property" },
    ["@lsp.type.type"]      = { link = "@type" },
    ["@lsp.type.keyword"]   = { link = "@keyword" },
    ["@lsp.type.string"]    = { link = "@string" },
    ["@lsp.type.enum"]      = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },

    -- Diagnostics
    DiagnosticError = { fg = s.err },
    DiagnosticWarn  = { fg = s.warning },
    DiagnosticInfo  = { fg = p.modeline_info },
    DiagnosticHint  = { fg = p.cyan },
    DiagnosticOk    = { fg = s.info },
    DiagnosticUnderlineError = { sp = s.err, undercurl = true },
    DiagnosticUnderlineWarn  = { sp = s.warning, undercurl = true },
    DiagnosticUnderlineInfo  = { sp = p.modeline_info, undercurl = true },
    DiagnosticUnderlineHint  = { sp = p.cyan, undercurl = true },
    DiagnosticVirtualTextError = { fg = s.err, bg = p.bg_red_subtle },
    DiagnosticVirtualTextWarn  = { fg = s.warning, bg = p.bg_yellow_subtle },
    DiagnosticVirtualTextInfo  = { fg = p.modeline_info, bg = p.bg_blue_subtle },
    DiagnosticVirtualTextHint  = { fg = p.cyan, bg = p.bg_cyan_subtle },

    -- LSP references / misc
    LspReferenceText  = { bg = p.bg_hover },
    LspReferenceRead  = { bg = p.bg_hover },
    LspReferenceWrite = { bg = p.bg_hover, bold = true },
    LspInlayHint      = { fg = p.fg_dim, bg = p.bg_dim },
    LspSignatureActiveParameter = { fg = s.variable_use, bold = true },

    -- Telescope
    TelescopeNormal        = { fg = p.fg_main, bg = p.bg_popup },
    TelescopeBorder        = { fg = p.border, bg = p.bg_popup },
    TelescopeTitle         = { fg = p.fg_main, bold = true },
    TelescopePromptNormal  = { fg = p.fg_main, bg = p.bg_dim },
    TelescopePromptBorder  = { fg = p.border, bg = p.bg_dim },
    TelescopePromptTitle   = { fg = p.bg_main, bg = s.accent_0, bold = true },
    TelescopePromptPrefix  = { fg = s.fg_prompt },
    TelescopePromptCounter = { fg = p.fg_dim },
    TelescopeResultsTitle  = { fg = p.bg_popup, bg = p.bg_popup },
    TelescopePreviewTitle  = { fg = p.bg_main, bg = s.accent_2, bold = true },
    TelescopeSelection     = { bg = p.bg_completion, fg = p.fg_main },
    TelescopeSelectionCaret = { fg = s.accent_1, bg = p.bg_completion },
    TelescopeMultiSelection = { fg = s.accent_3 },
    TelescopeMatching      = { fg = s.accent_1, bold = true },
    TelescopeResultsComment = { fg = p.fg_dim },

    -- Git signs (gitsigns.nvim)
    GitSignsAdd    = { fg = p.fg_added },
    GitSignsChange = { fg = p.fg_changed },
    GitSignsDelete = { fg = p.fg_removed },
  }

  for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

apply()

-- Re-apply when `background` is toggled, but only while this scheme is active.
local augroup = vim.api.nvim_create_augroup("StandardThemeBackground", { clear = true })
vim.api.nvim_create_autocmd("OptionSet", {
  group = augroup,
  pattern = "background",
  callback = function()
    if vim.g.colors_name == "standard" then
      apply()
    end
  end,
})
