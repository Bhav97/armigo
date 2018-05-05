#ifndef IRQHELPER_H
#define IRQHELPER_H

// this pair of functions has the following characteristics:
// - disables all ints
// - enables only IRQ, but not during interrupt service
void DisableInterrupts(void);
void EnableInterrupts(void);

#endif /* IRQHELPER_H */
