# HadesMods

## Wretched Broker QOL (Quality of Life) Mod

A quality-of-life enhancement mod for Hades that improves the Wretched Broker trading interface.

### Features

- **Custom Menu System**: Full-featured menu system with controller support
- **Bulk Trading**: Execute trades in bulk quantities (5, 10, 25, 50, 100, 500, 1000x multipliers)
- **Reverse Trading** (ReSell): Trade resources back in the opposite direction
- **Resource Icons**: Visual icons for all resource types (Gems, Keys, Nectar, Diamond, Ambrosia, Titan Blood)
- **Safe Cleanup**: Proper screen lifecycle management with cleanup on close

### Files

- `WretchedBrokerQOLMenuSystem.lua` - Main menu system implementation
- `tradeutils.lua` - Trade generation and formatting utilities

### Technical Details

#### Menu System (`WretchedBrokerQOLMenuSystem.lua`)

The menu system provides:
- Screen management with proper opening/closing
- Multi-page navigation with Previous/Next buttons
- Dynamic trade row generation with icons
- Button callback system with screen references
- Comprehensive error handling and nil-safety checks

#### Trade Utils (`tradeutils.lua`)

Provides utility functions for:
- Base trade definitions (matching vanilla Wretched Broker trades)
- Bulk trade generation with configurable multipliers
- Reverse (ReSell) trade generation
- Resource display name mapping
- Trade formatting for UI display

### Dependencies

**Required (Not Included):**
- `WretchedBrokerQOL.UIUtils` module with the following functions:
  - `CreateText(screen, fieldName, x, y, text, options)` - Creates text components
  - `CreateButton(screen, name, x, y, label, callback)` - Creates button components with `.Screen` property

**Hades Game APIs Used:**
- Screen management: `OnScreenOpened`, `OnScreenClosed`, `CloseScreen`
- Player control: `FreezePlayerUnit`, `UnfreezePlayerUnit`
- UI components: `CreateScreenComponent`, `CreateTextBox`, `SetAnimation`, `SetAlpha`
- Controller support: `EnableShopGamepadCursor`, `DisableShopGamepadCursor`
- Game state: `CurrentRun.CurrentRoom.Resources`

### Installation

1. Install ModUtil or your preferred Hades modding framework
2. Implement the `WretchedBrokerQOL.UIUtils` module (not included)
3. Place these files in your Hades mods directory
4. Load the mod according to your modding framework's instructions

### License

See [LICENSE](LICENSE) file for details.
