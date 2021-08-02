
#include <CPU_Gpio.h>

#if defined(__nuttx__)
#include <nuttx/config.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <nuttx/ioexpander/gpio.h>
#include <unistd.h>
#endif

#if defined(__nuttx__) && defined(NF_POSIX_GPIO)

static int openGpioCharDev(int chip)
{
    char devpath[20];
    int fd;
    int ret;

    sprintf(devpath, "/dev/gpio%d", chip);
    fd = open(devpath, O_RDWR);

    if (fd < 0)
    {
      int errcode = errno;
      fprintf(stderr, "ERROR: Failed to open %s: %d\n", devpath, errcode);
      exit(EXIT_FAILURE);
    }

    return fd;
}

static bool setGpioCharDevDir(int fd, GpioPinDriveMode dir, int pin)
{
    int ret;
    gpio_pintype_e nuttxDir;

    switch (dir)
    {
    case GpioPinDriveMode_Input:
        nuttxDir = GPIO_INPUT_PIN_PULLDOWN;
        break;
    
    case GpioPinDriveMode_Output:
        nuttxDir = GPIO_OUTPUT_PIN;
        break;
    
    default:
        break;
    }

    ret = ioctl(fd, GPIOC_SETDIR, (unsigned long)nuttxDir, pin);
    if (ret < 0)
    {
#if defined(DEBUG)
        int errcode = errno;
        fprintf(stderr,
                "ERROR: Failed to set dir from pin %d :: err %d\n",
                pin, errcode);
        // does not exit with EXIT_FAILURE
#endif
        return false;
    }

    return true;
}

static bool getGpioCharDevInValue(int fd, int pin)
{
    bool invalue;
    int ret;

    ret = ioctl(fd, GPIOC_READ, (unsigned long)((uintptr_t)&invalue), pin);

#if defined(DEBUG)
    if (ret < 0)
    {
        int errcode = errno;
        fprintf(stderr, "ERROR: Failed to read value %d\n", errcode);
        close(fd);
        exit(EXIT_FAILURE);
    }
#endif

    return invalue;
}

static void setGpioCharDevOutValue(int fd, int pin, bool outvalue)
{
    int ret;

    ret = ioctl(fd, GPIOC_WRITE, (unsigned long)outvalue, pin);

#if defined(DEBUG)
    if (ret < 0)
    {
        int errcode = errno;
        fprintf(stderr,
                "ERROR: Failed to write value %u err %d\n",
                (unsigned int)outvalue, errcode);
        close(fd);
        exit(EXIT_FAILURE);
    }
#endif
}

bool CPU_GPIO_Initialize()
{
    ioctrlFdReference[0] = openGpioCharDev(0);

    return true;
}

bool CPU_GPIO_Uninitialize()
{
    // for nuttx it's not needed for now because this is handled by char dev
    // TODO: Nuttx generc char device

    return true;
}

void CPU_GPIO_DisablePin(GPIO_PIN Pin, GpioPinDriveMode driveMode,
    uint32_t alternateFunction)
{
    GLOBAL_LOCK();
    CPU_GPIO_SetDriveMode(Pin, driveMode);

    // TODO
    // set PIN to alternateFunction

    GLOBAL_UNLOCK();

    CPU_GPIO_ReservePin(Pin, false);
}

bool CPU_GPIO_EnableOutputPin(GPIO_PIN Pin, GpioPinValue InitialState,
    GpioPinDriveMode driveMode)
{
    // check not an output drive mode
    if (driveMode < (int)GpioPinDriveMode_Output)
        return false;

    if (CPU_GPIO_SetDriveMode(Pin, driveMode) == false)
        return false;

    CPU_GPIO_SetPinState(Pin, InitialState);

    return true;
}

bool CPU_GPIO_EnableInputPin(
    GPIO_PIN pinNumber,
    CLR_UINT64 debounceTimeMilliseconds,
    GPIO_INTERRUPT_SERVICE_ROUTINE pin_ISR,
    void *isr_Param,
    GPIO_INT_EDGE intEdge,
    GpioPinDriveMode driveMode)
{
    // Check Input drive mode
    if (driveMode >= (int)GpioPinDriveMode_Output)
    {
        return false;
    }

    if (pin_ISR != NULL) {
        switch (intEdge)
        {
            case GPIO_INT_EDGE_LOW:
            case GPIO_INT_LEVEL_LOW:
            case GPIO_INT_EDGE_HIGH:
            case GPIO_INT_LEVEL_HIGH:
            case GPIO_INT_EDGE_BOTH:
                // TODO: IRQ callback not implemented
                return false;
                break;

            default:
                break;
        }
    }

    if (!CPU_GPIO_SetDriveMode(pinNumber, driveMode))
    {
        return false;
    }

    // not implemented :: debounce time
    // TODO
    return true;
}

GpioPinValue CPU_GPIO_GetPinState(GPIO_PIN Pin)
{
    enum gpio_pintype_e pintype;
    bool invalue;

    if (pinDirStored[Pin] == GpioPinDriveMode_Output)
        return pinLineValue[Pin];

    invalue = getGpioCharDevInValue(ioctrlFdReference[0], Pin);

    return invalue == 1 ? GpioPinValue_High : GpioPinValue_Low;
}

void CPU_GPIO_SetPinState(GPIO_PIN Pin, GpioPinValue PinState)
{
    pinLineValue[Pin] = PinState;
    setGpioCharDevOutValue(ioctrlFdReference[0], Pin, PinState);
}

void CPU_GPIO_TogglePinState(GPIO_PIN pinNumber)
{
    GpioPinValue value = CPU_GPIO_GetPinState(pinNumber);
    CPU_GPIO_SetPinState(pinNumber, (GpioPinValue) !value);
}

bool IsValidGpioPin(GPIO_PIN pinNumber)
{
    return (pinNumber <= GPIO_MAX_PIN);
}

bool CPU_GPIO_PinIsBusy(GPIO_PIN Pin)
{
    // TODO
    return IsValidGpioPin(Pin);
}

bool CPU_GPIO_ReservePin(GPIO_PIN Pin, bool fReserve)
{
    // TODO
    return true;
}

int32_t CPU_GPIO_GetPinCount()
{
    return GPIO_MAX_PIN;
}

uint32_t CPU_GPIO_GetPinDebounce(GPIO_PIN Pin)
{
    // TODO
    return 0;
}

bool CPU_GPIO_SetPinDebounce(GPIO_PIN pinNumber, CLR_UINT64 debounceTimeMilliseconds)
{
    // TODO
    return true;
}

bool CPU_GPIO_SetDriveMode(GPIO_PIN pinNumber, GpioPinDriveMode driveMode)
{
    if (CPU_GPIO_DriveModeSupported(pinNumber, driveMode)) {
        pinDirStored[pinNumber] = driveMode;
        return true;
    }

    return false;
}

bool CPU_GPIO_DriveModeSupported(GPIO_PIN pinNumber, GpioPinDriveMode driveMode)
{
   return setGpioCharDevDir(ioctrlFdReference[0], driveMode, pinNumber);
}

#endif
