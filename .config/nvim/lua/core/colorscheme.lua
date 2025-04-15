local status, _ = pcall(vim.cmd, "colorscheme lcarsoft") --favorite
if not status then
    print("Colorscheme not found !")
    return
end
