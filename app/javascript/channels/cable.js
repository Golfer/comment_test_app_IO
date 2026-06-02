import { createConsumer } from "@rails/actioncable"

let consumer

export function getCableConsumer() {
  if (!consumer) consumer = createConsumer()
  return consumer
}

export function subscribeToChannel(channelName, onReceived) {
  return getCableConsumer().subscriptions.create(
    { channel: channelName },
    { received: onReceived }
  )
}
