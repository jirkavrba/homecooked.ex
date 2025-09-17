import {
  ActionRowBuilder,
  ButtonBuilder,
  ButtonStyle,
  Client,
  EmbedBuilder,
  Events,
  GatewayIntentBits,
  MessageFlagsBitField,
} from "discord.js";
import { createMagicLink } from "./api.ts";

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages],
});

client.once(Events.ClientReady, (bot) => {
  console.log(`Ready! Logged in as ${bot.user.tag}`);
});

client.on(Events.InteractionCreate, async (event) => {
  console.log("Received an interaction: ", event);

  if (event.isMessageComponent() && event.customId === "login") {
    const avatar = event.user.displayAvatarURL({ extension: "png" });
    const username = event.user.username;
    const displayName = event.user.displayName || event.user.username;

    console.log("Creating a magic link for the user: ", { username, avatar });

    const link = await createMagicLink(
      event.user.id,
      displayName,
      username,
      avatar,
    );

    console.log("Created magic link: ", link);

    const button = new ButtonBuilder()
      .setStyle(ButtonStyle.Link)
      .setLabel("Odkaz pro přihlášení")
      .setURL(link);

    const row = new ActionRowBuilder().addComponents(button).toJSON();

    const embed = new EmbedBuilder()
      .setTitle("Odkaz pro přihlášení")
      .setThumbnail(
        `https://api.qrserver.com/v1/create-qr-code/?size=200x200&margin=20&data=${encodeURIComponent(link)}`,
      )
      .setDescription(
        "Po kliknutí na tlačítko pod zprávou nebo naskenování QR kódu tě aplikace automaticky přihlásí.",
      )
      .addFields({
        name: "Odkaz pro přihlášení",
        value: link,
        inline: false,
      })
      .setColor("#fcba03");

    console.log("Sending response with the magic link.");

    await event.reply({
      flags: [MessageFlagsBitField.Flags.Ephemeral],
      embeds: [embed],
      components: [row],
    });
  }
});

await client.login(process.env.DISCORD_TOKEN);
